import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../entities/image_result.dart';
import '../entities/prompt.dart';

/// Repository interface for image generation operations
abstract class ImageGenerationRepository {
  /// Generate an image from text prompt
  Future<ImageResult> generateFromText(
    Prompt prompt, {
    CancelToken? cancelToken,
  });

  /// Edit an existing image with a prompt
  Future<ImageResult> editImage(
    Uint8List imageBytes,
    Prompt prompt, {
    CancelToken? cancelToken,
  });

  /// Compose multiple images with a prompt
  Future<ImageResult> composeImages(
    List<Uint8List> imageBytesList,
    Prompt prompt, {
    CancelToken? cancelToken,
  });

  /// Cancel a generation job
  Future<void> cancelJob(String jobId);

  /// Get job status
  Future<GenerationJob?> getJobStatus(String jobId);

  /// Stream job updates (for real-time progress)
  Stream<GenerationJob> watchJob(String jobId);
}
