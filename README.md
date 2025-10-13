# Dreamify 🎨

AI-powered image generation and editing app using Gemini 2.5 Flash Image API.

## Features

### Core Functionality
- **Text-to-Image Generation**: Create images from text descriptions
- **Image Editing**: Edit existing images with natural language prompts
- **Multi-Image Composition**: Combine multiple images with intelligent blending
- **Refinement Chat**: Iteratively improve your creations with conversational editing
- **Version History**: Track and revert to previous versions
- **Style Presets**: Quick-apply artistic styles (anime, photorealistic, cyberpunk, etc.)

### User Experience
- **No Registration Required**: Start creating immediately with 3 free credits
- **Freemium Model**: Free tier with watermark, Premium for unlimited access
- **Real-time Progress**: Watch your images being created
- **Gallery Management**: Organize creations with tags and collections
- **Social Sharing**: Export to Instagram, TikTok, Snapchat with optimized formats

### Premium Features
- Unlimited generations
- High & Ultra quality (up to 2048px)
- No watermark
- Priority queue
- Advanced style presets
- Background removal
- Export in multiple formats

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/              # Shared utilities, theme, constants
├── di/                # Dependency injection (Riverpod providers)
├── routing/           # Navigation (go_router)
└── features/
    ├── generation/    # Image generation feature
    │   ├── domain/           # Entities & repository interfaces
    │   ├── application/      # Business logic & state management
    │   ├── infrastructure/   # External services (Gemini API)
    │   └── presentation/     # UI (screens & widgets)
    ├── gallery/       # Gallery management
    ├── billing/       # In-app purchases
    ├── settings/      # App settings
    └── onboarding/    # First-time user experience
```

### Tech Stack

- **Framework**: Flutter 3.22+, Dart 3.7+
- **State Management**: Riverpod
- **Navigation**: go_router
- **Networking**: Dio + Retrofit
- **Local Storage**: Hive
- **Image Processing**: image package + isolates
- **Monetization**: in_app_purchase
- **Analytics**: Firebase (Analytics, Crashlytics, Remote Config)

## Getting Started

### Prerequisites

- Flutter SDK 3.22 or higher
- Dart SDK 3.7 or higher
- iOS: Xcode 15+ (for iOS development)
- Android: Android Studio with SDK 21+ (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dreamify.git
   cd dreamify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**

   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Configure Firebase** (Optional but recommended)

   - Create a Firebase project at https://console.firebase.google.com
   - Add iOS and Android apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### iOS
```bash
flutter build ios --release
# Or open in Xcode:
open ios/Runner.xcworkspace
```

#### Android
```bash
flutter build apk --release
# Or for app bundle:
flutter build appbundle --release
```

## Configuration

### API Keys

The app requires a Gemini API key for the **Gemini 2.5 Flash Image API**.

**Get your API key:**
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create a new API key
3. Enable the Gemini API for your project

**Set the API key:**

```dart
// Using --dart-define
flutter run --dart-define=GEMINI_API_KEY=your_key_here

// Or in your .env file (recommended)
GEMINI_API_KEY=your_key_here
```

**Note:** The app uses the `gemini-2.5-flash-image` model which supports:
- Text-to-image generation
- Image editing with up to 3 input images
- Automatic SynthID watermarking
- Cost: 1290 tokens per image generated

### In-App Purchase Product IDs

Configure your IAP products in:
- `lib/features/billing/infrastructure/billing_service.dart`
- Update `monthlyProductId` and `yearlyProductId`

Register these IDs in:
- **iOS**: App Store Connect
- **Android**: Google Play Console

## Testing

### Run all tests
```bash
flutter test
```

### Run specific test suites
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

### Code coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Project Structure Details

### Domain Layer
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces for data operations

### Application Layer
- **Notifiers**: Riverpod StateNotifiers managing feature state
- **Use Cases**: Business logic operations

### Infrastructure Layer
- **Services**: Concrete implementations of repositories
- **DTOs**: Data Transfer Objects for API communication
- **Mappers**: Convert between DTOs and domain entities

### Presentation Layer
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Controllers**: UI-specific logic

## Key Classes

### Generation Feature

**Entities:**
- `Prompt`: User's generation request with style, aspect ratio, quality
- `ImageResult`: Generated/edited image with metadata
- `GenerationJob`: Async job tracking

**Services:**
- `GeminiImageService`: Communicates with Gemini API
  - Retry logic with exponential backoff
  - Progress tracking via streams
  - Cancellation support

**Notifiers:**
- `EditorNotifier`: Manages editor state and generation workflow

### Gallery Feature

**Entities:**
- `GalleryItem`: Saved creation with metadata
- `GalleryCollection`: Grouped items

**Services:**
- `LocalStorageService`: Hive-based local persistence
  - Image file management
  - Thumbnail generation
  - Search and filtering

### Billing Feature

**Entities:**
- `UserSubscription`: Current subscription status
- `SubscriptionProduct`: Available IAP products
- `PurchaseTransaction`: Purchase records

**Services:**
- `BillingService`: In-app purchase management
  - Product fetching
  - Purchase flow
  - Restore purchases

## TODO List

High-priority items to complete before production:

### Critical
1. ~~**Gemini API Integration**: Implement actual API calls in `GeminiImageService`~~ ✅ **COMPLETED**
   - ~~Replace mock implementations~~ ✅
   - ~~Add proper error handling~~ ✅
   - ~~Implement response parsing~~ ✅
   - **Updated to use Gemini 2.5 Flash Image API (`gemini-2.5-flash-image`)**
   - **API endpoint:** `https://generativelanguage.googleapis.com/v1beta`

2. ~~**Image Processing**: Complete base64 encoding/decoding~~ ✅ **COMPLETED**
   - ~~`_bytesToBase64()` in `gemini_image_service.dart`~~ ✅
   - ~~`_extractImageBytes()` for API responses~~ ✅

3. **Firebase Setup**: Initialize Firebase services
   - Uncomment initialization in `main.dart`
   - Configure Analytics events
   - Set up Crashlytics

4. **Hive Initialization**: Set up local storage
   - Initialize Hive in `main.dart`
   - Register type adapters if needed

5. **IAP Implementation**: Complete in-app purchase flow
   - Test purchase flow on TestFlight/Internal Testing
   - Implement restore purchases
   - Handle subscription status

### Important
6. **Permissions**: Request camera and photo library access
   - Add permission_handler logic
   - Show permission rationale dialogs

7. **Image Export**: Implement save to device gallery
   - Use photo_manager package
   - Handle platform-specific saving

8. **Share Functionality**: Implement social sharing
   - Use share_plus package
   - Generate optimized previews

9. **Multi-Image Picker**: Enable composition feature
   - Implement multi-select image picker
   - Add image preview before composition

10. **Error Messages**: Localize and improve error handling
    - User-friendly error messages
    - Network connectivity checks
    - Graceful degradation

### Nice-to-Have
11. **Animations**: Add micro-interactions
    - Hero transitions
    - Loading animations
    - Success celebrations

12. **Accessibility**: Improve a11y
    - Screen reader support
    - High contrast mode
    - Keyboard navigation

13. **Localization**: Add i18n support
    - Hebrew (he-IL)
    - English (en-US)
    - RTL layout support

14. **Analytics**: Implement tracking
    - Generation events
    - Paywall conversion
    - Feature usage

15. **Remote Config**: A/B testing setup
    - Feature flags
    - Pricing experiments
    - UI variations

## Deployment Checklist

### iOS
- [ ] Update version and build number
- [ ] Configure App Store Connect
- [ ] Add screenshots (use `golden_toolkit`)
- [ ] Create Privacy Manifest
- [ ] Set up TestFlight
- [ ] Submit for review

### Android
- [ ] Update version code and name
- [ ] Generate upload keystore
- [ ] Configure Play Console
- [ ] Add screenshots
- [ ] Create release notes
- [ ] Submit to Internal Testing

### Both Platforms
- [ ] Test IAP in production mode
- [ ] Verify deep links
- [ ] Test on physical devices
- [ ] Performance profiling
- [ ] Security audit

## CI/CD

GitHub Actions workflow is provided for:
- Automated testing
- Code analysis
- Build artifacts generation

See `.github/workflows/main.yml` for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@dreamify.app or open an issue on GitHub.

## Acknowledgments

- Gemini API for AI-powered generation
- Flutter team for the amazing framework
- Riverpod for state management
- All open-source contributors

---

**Built with ❤️ using Flutter**
