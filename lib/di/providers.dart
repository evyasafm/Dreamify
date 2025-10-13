import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../core/constants/app_constants.dart';
import '../features/generation/domain/repositories/image_generation_repository.dart';
import '../features/generation/infrastructure/services/gemini_image_service.dart';
import '../features/gallery/domain/repositories/gallery_repository.dart';
import '../features/gallery/infrastructure/local_storage_service.dart';
import '../features/billing/domain/repositories/billing_repository.dart';
import '../features/billing/infrastructure/billing_service.dart';

// Core Providers

/// Logger provider
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );
});

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.geminiApiUrl,
      connectTimeout: AppConstants.networkTimeout,
      receiveTimeout: AppConstants.generationTimeout,
      sendTimeout: AppConstants.networkTimeout,
    ),
  );

  // Add interceptors
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => ref.read(loggerProvider).d(obj),
    ),
  );

  return dio;
});

/// API Key provider (TODO: Move to secure storage or env)
final apiKeyProvider = Provider<String>((ref) {
  // TODO: Load from .env or secure storage
  return const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );
});

// Repository Providers

/// Image generation repository provider
final imageGenerationRepositoryProvider =
    Provider<ImageGenerationRepository>((ref) {
  return GeminiImageService(
    dio: ref.watch(dioProvider),
    apiKey: ref.watch(apiKeyProvider),
    logger: ref.watch(loggerProvider),
  );
});

/// Gallery repository provider
final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final storage = LocalStorageService(
    logger: ref.watch(loggerProvider),
  );

  // Initialize storage
  storage.initialize();

  return storage;
});

/// Billing repository provider
final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingService(
    logger: ref.watch(loggerProvider),
  );
});

// Feature Providers will be added here by feature-specific files
