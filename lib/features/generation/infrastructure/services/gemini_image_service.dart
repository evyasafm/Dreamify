import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/image_result.dart';
import '../../domain/entities/prompt.dart';
import '../../domain/repositories/image_generation_repository.dart';

/// Service for interacting with Gemini Image Generation API
class GeminiImageService implements ImageGenerationRepository {
  GeminiImageService({
    required Dio dio,
    required String apiKey,
    Logger? logger,
  })  : _dio = dio,
        _apiKey = apiKey,
        _logger = logger ?? Logger();

  final Dio _dio;
  final String _apiKey;
  final Logger _logger;
  final _uuid = const Uuid();
  final Map<String, CancelToken> _activeJobs = {};
  final Map<String, StreamController<GenerationJob>> _jobStreams = {};

  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String imageModel = 'gemini-2.5-flash-image';
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  @override
  Future<ImageResult> generateFromText(
    Prompt prompt, {
    CancelToken? cancelToken,
  }) async {
    final jobId = _uuid.v4();
    final token = cancelToken ?? CancelToken();
    _activeJobs[jobId] = token;

    try {
      _logger.i('Starting text-to-image generation: ${prompt.text}');

      final startTime = DateTime.now();
      final dimensions = prompt.aspectRatio.getDimensions(prompt.quality.resolution);

      // Create job stream
      final streamController = StreamController<GenerationJob>.broadcast();
      _jobStreams[jobId] = streamController;

      // Emit initial job state
      final job = GenerationJob(
        id: jobId,
        prompt: prompt.text,
        status: JobStatus.processing,
        createdAt: startTime,
        progress: 0.1,
      );
      streamController.add(job);

      final response = await _retryRequest(
        () => _dio.post(
          '$baseUrl/models/$imageModel:generateContent?key=$_apiKey',
          data: {
            'contents': [
              {
                'parts': [
                  {'text': _buildPromptText(prompt)},
                ],
              },
            ],
            'generationConfig': {
              'responseModalities': ['image'],
              'imageConfig': {
                'aspectRatio': prompt.aspectRatio.label,
              },
            },
          },
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          ),
          cancelToken: token,
        ),
      );

      // Update progress
      streamController.add(job.copyWith(progress: 0.8));

      if (response.statusCode != 200) {
        throw _handleErrorResponse(response);
      }

      final imageBytes = _extractImageBytes(response.data);
      final duration = DateTime.now().difference(startTime);

      final result = ImageResult(
        id: jobId,
        bytes: imageBytes,
        createdAt: DateTime.now(),
        meta: {
          'prompt': prompt.text,
          'aspectRatio': prompt.aspectRatio.label,
          'quality': prompt.quality.name,
          'durationMs': duration.inMilliseconds,
          'creditCost': 1,
          'hasWatermark': true, // Always add watermark for free tier
        },
      );

      // Emit completion
      streamController.add(job.copyWith(
        status: JobStatus.completed,
        progress: 1.0,
        result: result,
      ));
      await streamController.close();

      _logger.i('Generation completed in ${duration.inMilliseconds}ms');
      return result;
    } on DioException catch (e) {
      _logger.e('Dio error during generation', error: e);
      _emitJobError(jobId, _mapDioException(e));
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during generation', error: e);
      _emitJobError(jobId, e);
      rethrow;
    } finally {
      _activeJobs.remove(jobId);
      _jobStreams.remove(jobId);
    }
  }

  @override
  Future<ImageResult> editImage(
    Uint8List imageBytes,
    Prompt prompt, {
    CancelToken? cancelToken,
  }) async {
    final jobId = _uuid.v4();
    final token = cancelToken ?? CancelToken();
    _activeJobs[jobId] = token;

    try {
      _logger.i('Starting image editing: ${prompt.text}');

      final startTime = DateTime.now();
      final base64Image = _bytesToBase64(imageBytes);

      final response = await _retryRequest(
        () => _dio.post(
          '$baseUrl/models/$imageModel:generateContent?key=$_apiKey',
          data: {
            'contents': [
              {
                'parts': [
                  {
                    'inline_data': {
                      'mime_type': 'image/png',
                      'data': base64Image,
                    },
                  },
                  {'text': _buildPromptText(prompt)},
                ],
              },
            ],
            'generationConfig': {
              'responseModalities': ['image'],
            },
          },
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          ),
          cancelToken: token,
        ),
      );

      if (response.statusCode != 200) {
        throw _handleErrorResponse(response);
      }

      final resultBytes = _extractImageBytes(response.data);
      final duration = DateTime.now().difference(startTime);

      final result = ImageResult(
        id: jobId,
        bytes: resultBytes,
        createdAt: DateTime.now(),
        meta: {
          'prompt': prompt.text,
          'durationMs': duration.inMilliseconds,
          'creditCost': 1,
          'hasWatermark': true,
          'operationType': 'edit',
        },
      );

      _logger.i('Edit completed in ${duration.inMilliseconds}ms');
      return result;
    } on DioException catch (e) {
      _logger.e('Dio error during edit', error: e);
      throw _mapDioException(e);
    } finally {
      _activeJobs.remove(jobId);
    }
  }

  @override
  Future<ImageResult> composeImages(
    List<Uint8List> imageBytesList,
    Prompt prompt, {
    CancelToken? cancelToken,
  }) async {
    final jobId = _uuid.v4();
    final token = cancelToken ?? CancelToken();
    _activeJobs[jobId] = token;

    try {
      _logger.i('Starting image composition with ${imageBytesList.length} images');

      final startTime = DateTime.now();
      final parts = imageBytesList.map<Map<String, dynamic>>((bytes) => {
            'inline_data': {
              'mime_type': 'image/png',
              'data': _bytesToBase64(bytes),
            },
          }).toList();

      parts.add(<String, dynamic>{'text': _buildPromptText(prompt)});

      final response = await _retryRequest(
        () => _dio.post(
          '$baseUrl/models/$imageModel:generateContent?key=$_apiKey',
          data: {
            'contents': [
              {'parts': parts},
            ],
            'generationConfig': {
              'responseModalities': ['image'],
            },
          },
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          ),
          cancelToken: token,
        ),
      );

      if (response.statusCode != 200) {
        throw _handleErrorResponse(response);
      }

      final resultBytes = _extractImageBytes(response.data);
      final duration = DateTime.now().difference(startTime);

      final result = ImageResult(
        id: jobId,
        bytes: resultBytes,
        createdAt: DateTime.now(),
        meta: {
          'prompt': prompt.text,
          'durationMs': duration.inMilliseconds,
          'creditCost': 2, // Composition costs more
          'hasWatermark': true,
          'operationType': 'compose',
          'inputCount': imageBytesList.length,
        },
      );

      _logger.i('Composition completed in ${duration.inMilliseconds}ms');
      return result;
    } on DioException catch (e) {
      _logger.e('Dio error during composition', error: e);
      throw _mapDioException(e);
    } finally {
      _activeJobs.remove(jobId);
    }
  }

  @override
  Future<void> cancelJob(String jobId) async {
    final token = _activeJobs[jobId];
    if (token != null && !token.isCancelled) {
      token.cancel('User cancelled');
      _activeJobs.remove(jobId);
      _emitJobCancellation(jobId);
      _logger.i('Job $jobId cancelled');
    }
  }

  @override
  Future<GenerationJob?> getJobStatus(String jobId) async {
    // In a real implementation, this would query the API
    // For now, we return null as jobs are synchronous
    return null;
  }

  @override
  Stream<GenerationJob> watchJob(String jobId) {
    final controller = _jobStreams[jobId];
    if (controller == null) {
      return Stream.error('Job not found');
    }
    return controller.stream;
  }

  // Helper methods

  String _buildPromptText(Prompt prompt) {
    final buffer = StringBuffer(prompt.text);

    if (prompt.styleTags.isNotEmpty) {
      buffer.write(' Style: ${prompt.styleTags.join(", ")}');
    }

    return buffer.toString();
  }

  String _bytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  Uint8List _extractImageBytes(Map<String, dynamic> responseData) {
    try {
      // Gemini API returns images in the response as base64-encoded strings
      // Response format: { "candidates": [{ "content": { "parts": [{ "inline_data": { "data": "base64..." } }] } }] }
      final candidates = responseData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const ServerFailure('No candidates in response');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw const ServerFailure('No content in response');
      }

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw const ServerFailure('No parts in response');
      }

      // Find the first part with inline_data
      for (final part in parts) {
        final inlineData = part['inline_data'] as Map<String, dynamic>?;
        if (inlineData != null) {
          final base64Data = inlineData['data'] as String?;
          if (base64Data != null) {
            return base64Decode(base64Data);
          }
        }
      }

      throw const ServerFailure('No image data found in response');
    } catch (e) {
      _logger.e('Error extracting image bytes', error: e);
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to extract image: ${e.toString()}');
    }
  }

  Future<Response<T>> _retryRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        attempts++;
        if (attempts >= maxRetries || !_shouldRetry(e)) {
          rethrow;
        }
        _logger.w('Retry attempt $attempts after error: ${e.message}');
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw const ServerFailure('Max retries exceeded');
  }

  bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.cancel) return false;
    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      return statusCode != null && statusCode >= 500;
    }
    return true;
  }

  Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        return _handleErrorResponse(e.response);
      case DioExceptionType.cancel:
        return const CancellationFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      default:
        return GenericFailure(e.message ?? 'Unknown error');
    }
  }

  Failure _handleErrorResponse(Response? response) {
    if (response == null) {
      return const ServerFailure('No response from server');
    }

    final statusCode = response.statusCode;
    final message = response.data?['error']?['message'] ?? 'Server error';

    switch (statusCode) {
      case 400:
        return ValidationFailure(message);
      case 401:
      case 403:
        return AuthFailure(message);
      case 429:
        return const ServerFailure('Rate limit exceeded');
      case 402:
        return const InsufficientCreditsFailure('Insufficient credits');
      case 500:
      case 503:
        return ServerFailure(message);
      default:
        return ServerFailure('HTTP $statusCode: $message');
    }
  }

  void _emitJobError(String jobId, Object error) {
    final controller = _jobStreams[jobId];
    if (controller != null && !controller.isClosed) {
      controller.addError(error);
      controller.close();
    }
  }

  void _emitJobCancellation(String jobId) {
    final controller = _jobStreams[jobId];
    if (controller != null && !controller.isClosed) {
      final job = GenerationJob(
        id: jobId,
        prompt: '',
        status: JobStatus.cancelled,
        createdAt: DateTime.now(),
      );
      controller.add(job);
      controller.close();
    }
  }
}
