/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Dreamify';
  static const String appVersion = '1.0.0';

  // Credits & Limits
  static const int freeCreditsPerDay = 3;
  static const int premiumCreditBuffer = 100;

  // Generation Limits
  static const int maxPromptLength = 500;
  static const int maxImagesForComposition = 5;
  static const int minPromptLength = 3;

  // Storage
  static const int maxCachedImages = 50;
  static const int maxLocalImages = 200;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 60);
  static const Duration generationTimeout = Duration(seconds: 120);

  // API
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enableRemoteConfig = true;

  // Premium Features
  static const List<String> premiumFeatures = [
    'high_quality',
    'ultra_quality',
    'no_watermark',
    'unlimited_generations',
    'priority_queue',
    'advanced_styles',
    'export_hd',
    'remove_background',
  ];

  // Style Tags
  static const List<String> stylePresets = [
    'anime',
    'photorealistic',
    'oil painting',
    'watercolor',
    'pencil sketch',
    'digital art',
    'cyberpunk',
    'fantasy',
    'minimalist',
    'vintage',
    'neon',
    'renaissance',
    'modern',
    '3d render',
    'cartoon',
  ];

  // Quick Actions
  static const List<String> quickPrompts = [
    'Make it darker',
    'Make it brighter',
    'Change background',
    'Add more details',
    'Simplify',
    'Make it colorful',
    'Make it monochrome',
    'Add depth',
  ];
}
