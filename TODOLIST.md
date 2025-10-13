# Dreamify - Development TODO List

## 🔴 Critical (Must Complete Before First Build)

### 1. Gemini API Integration
- [ ] Implement actual API endpoint calls in `GeminiImageService`
- [ ] Replace mock `_bytesToBase64()` with real base64 encoding (use dart:convert)
- [ ] Implement `_extractImageBytes()` to parse API responses
- [ ] Test with real Gemini API key
- [ ] Handle different response formats
- [ ] Add proper timeout handling

**File**: `lib/features/generation/infrastructure/services/gemini_image_service.dart`

### 2. Firebase Initialization
- [ ] Uncomment Firebase initialization in `main.dart`
- [ ] Add google-services.json for Android
- [ ] Add GoogleService-Info.plist for iOS
- [ ] Test Analytics logging
- [ ] Configure Crashlytics
- [ ] Set up Remote Config parameters

**Files**:
- `lib/main.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 3. Hive Local Storage
- [ ] Uncomment Hive.initFlutter() in `main.dart`
- [ ] Test gallery item saving
- [ ] Test collections creation
- [ ] Verify thumbnail generation works
- [ ] Test search functionality

**File**: `lib/main.dart`, `lib/features/gallery/infrastructure/local_storage_service.dart`

### 4. In-App Purchases
- [ ] Create IAP products in App Store Connect
- [ ] Create IAP products in Google Play Console
- [ ] Update product IDs in `BillingService`
- [ ] Test purchase flow in sandbox
- [ ] Implement restore purchases
- [ ] Handle purchase verification
- [ ] Add subscription status checking

**File**: `lib/features/billing/infrastructure/billing_service.dart`

### 5. Permissions Handling
- [ ] Add permission_handler usage for camera
- [ ] Add permission_handler usage for photo library
- [ ] Create permission request dialogs with rationale
- [ ] Update AndroidManifest.xml with permissions
- [ ] Update Info.plist with permission descriptions
- [ ] Handle permission denied scenarios

**Files**:
- iOS: `ios/Runner/Info.plist`
- Android: `android/app/src/main/AndroidManifest.xml`

---

## 🟡 Important (Complete Before MVP Release)

### 6. Image Export to Gallery
- [ ] Implement `exportToDevice()` in `LocalStorageService`
- [ ] Use photo_manager to save to device gallery
- [ ] Handle platform-specific paths (iOS vs Android)
- [ ] Show success/error messages
- [ ] Add export button in gallery item screen

**File**: `lib/features/gallery/infrastructure/local_storage_service.dart`

### 7. Social Sharing
- [ ] Implement share functionality using share_plus
- [ ] Generate optimized previews (1:1, 16:9, 9:16)
- [ ] Add watermark overlay for free tier
- [ ] Remove watermark for premium users
- [ ] Test sharing to Instagram, TikTok, Snapchat
- [ ] Handle share failures gracefully

**Files**: New file `lib/core/utils/share_helper.dart`

### 8. Multi-Image Picker
- [ ] Implement multi-select image picker
- [ ] Show preview grid before composition
- [ ] Add remove/reorder functionality
- [ ] Limit to max 5 images (AppConstants.maxImagesForComposition)
- [ ] Update Editor screen to handle multiple inputs
- [ ] Test composition API call

**File**: `lib/features/generation/presentation/screens/home_screen.dart`

### 9. Error Handling Improvements
- [ ] Create user-friendly error messages (localized)
- [ ] Add network connectivity checks before API calls
- [ ] Implement retry mechanisms with user feedback
- [ ] Handle insufficient credits gracefully
- [ ] Show paywall when credits exhausted
- [ ] Add offline mode indicators

**Files**: `lib/core/errors/failures.dart`, Create `lib/core/utils/error_handler.dart`

### 10. Gallery Implementation
- [ ] Fetch and display gallery items in grid
- [ ] Implement search functionality
- [ ] Add filter by tags/collections
- [ ] Implement item deletion with confirmation
- [ ] Add favorite toggle
- [ ] Create collection management UI
- [ ] Show empty state properly

**File**: `lib/features/gallery/presentation/screens/gallery_screen.dart`

---

## 🟢 Nice-to-Have (Post-Launch Enhancements)

### 11. Animations & Micro-Interactions
- [ ] Add Hero transitions between screens
- [ ] Create custom loading animations (painting effect)
- [ ] Add success celebration animation (Lottie)
- [ ] Smooth scroll animations in history timeline
- [ ] Fade transitions for image results
- [ ] Haptic feedback on important actions

### 12. Accessibility (a11y)
- [ ] Add Semantics to all interactive widgets
- [ ] Test with screen readers (TalkBack/VoiceOver)
- [ ] Ensure minimum contrast ratios (WCAG AA)
- [ ] Add focus indicators for keyboard navigation
- [ ] Test with large text sizes
- [ ] Add image alt descriptions

### 13. Internationalization (i18n)
- [ ] Set up flutter_localizations
- [ ] Create ARB files for en-US and he-IL
- [ ] Translate all UI strings
- [ ] Implement RTL layout support for Hebrew
- [ ] Test date/number formatting
- [ ] Add language selector in settings

**Files**: Create `lib/l10n/` directory

### 14. Analytics Implementation
- [ ] Define analytics events (see README)
- [ ] Log `app_open` event
- [ ] Log generation events (success/fail)
- [ ] Log paywall views and conversions
- [ ] Track feature usage
- [ ] Set user properties (tier, credits)
- [ ] Test analytics in Firebase Console

**File**: Create `lib/core/services/analytics_service.dart`

### 15. Remote Config & A/B Testing
- [ ] Set up remote config parameters
- [ ] Create feature flags (premium features)
- [ ] Add pricing experiment variants
- [ ] Implement UI variation tests
- [ ] Fetch and apply config on startup
- [ ] Add fallback values

**File**: Create `lib/core/services/remote_config_service.dart`

---

## 📱 Platform-Specific Tasks

### iOS
- [ ] Create App Icon (1024x1024)
- [ ] Create Splash Screen
- [ ] Add Privacy Manifest (required by Apple)
- [ ] Configure Info.plist keys:
  - Camera usage description
  - Photo library usage description
  - Photo library add usage description
- [ ] Set up deep links/universal links
- [ ] Configure StoreKit for IAP
- [ ] Test on physical iOS device
- [ ] Create App Store screenshots (6.7", 6.5", 5.5")

### Android
- [ ] Create App Icon (adaptive icon)
- [ ] Create Splash Screen
- [ ] Configure AndroidManifest.xml:
  - Camera permission
  - Storage permissions
  - Internet permission
- [ ] Set up deep links/app links
- [ ] Configure Google Play Billing
- [ ] Generate upload keystore
- [ ] Test on physical Android device
- [ ] Create Play Store screenshots (phone, tablet)

---

## 🧪 Testing Tasks

### Unit Tests
- [x] Prompt entity tests
- [x] ImageResult entity tests
- [ ] Subscription entity tests
- [ ] GalleryItem entity tests
- [ ] GeminiImageService tests (with mocks)
- [ ] LocalStorageService tests
- [ ] BillingService tests
- [ ] EditorNotifier tests

### Widget Tests
- [ ] HomeScreen widget test
- [ ] EditorScreen widget test
- [ ] PaywallScreen widget test
- [ ] GalleryScreen widget test
- [ ] ImageResultViewer widget test
- [ ] VersionHistoryTimeline widget test

### Integration Tests
- [ ] Full generation flow: Home → Editor → Generate → Save
- [ ] Purchase flow: Paywall → Select plan → Purchase → Verify
- [ ] Gallery flow: Create → View → Edit → Share
- [ ] Onboarding flow: Skip vs Complete

---

## 🚀 Pre-Launch Checklist

### Code Quality
- [ ] Run `flutter analyze` with no issues
- [ ] Run `flutter test` with 100% passing
- [ ] Achieve >70% code coverage
- [ ] Format all code: `flutter format .`
- [ ] Remove all TODO comments from code
- [ ] Remove debug print statements

### Performance
- [ ] Profile app with DevTools
- [ ] Check for memory leaks
- [ ] Optimize image loading/caching
- [ ] Test on low-end devices
- [ ] Ensure smooth 60fps UI
- [ ] Check app size (< 50MB)

### Security
- [ ] Never commit API keys to git
- [ ] Use .env for sensitive data
- [ ] Implement certificate pinning (optional)
- [ ] Validate all user inputs
- [ ] Sanitize prompts before API calls
- [ ] Secure local storage encryption (optional)

### Documentation
- [x] Complete README.md
- [ ] Add code comments to complex logic
- [ ] Document API integration
- [ ] Create CHANGELOG.md
- [ ] Write release notes

---

## 📦 Deployment Tasks

### TestFlight (iOS)
- [ ] Create App Store Connect record
- [ ] Upload build via Xcode
- [ ] Add beta testers
- [ ] Collect feedback
- [ ] Fix critical bugs

### Internal Testing (Android)
- [ ] Create Play Console record
- [ ] Upload AAB file
- [ ] Add internal testers
- [ ] Collect feedback
- [ ] Fix critical bugs

### Production Release
- [ ] Update version numbers
- [ ] Create release tags
- [ ] Submit to App Store review
- [ ] Submit to Play Store review
- [ ] Prepare marketing materials
- [ ] Set up support email/website

---

## 🔧 Known Issues / Tech Debt

1. **GeminiImageService**: Mock implementations need real API calls
2. **Base64 encoding**: Not implemented yet
3. **Image extraction**: Response parsing incomplete
4. **Gallery persistence**: Not fully connected to UI
5. **IAP flow**: Sandbox testing needed
6. **Error messages**: Too technical, need user-friendly versions
7. **Network checks**: Missing connectivity verification
8. **Isolates**: Not used for image processing yet
9. **Watermark**: Not actually applied to images
10. **Analytics**: Events defined but not logged

---

## 📝 Notes

- Priority order: Critical → Important → Nice-to-Have
- Estimated MVP timeline: 2-3 weeks (with API access)
- Target platforms: iOS 13+, Android 6.0+ (API 23+)
- Consider using feature branches for major features
- Run tests before every commit
- Keep dependencies updated regularly

**Last Updated**: 2025-10-12
