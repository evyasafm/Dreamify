import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/generation/presentation/screens/home_screen.dart';
import '../features/generation/presentation/screens/editor_screen.dart';
import '../features/gallery/presentation/screens/gallery_screen.dart';
import '../features/gallery/presentation/screens/gallery_item_screen.dart';
import '../features/billing/presentation/paywall_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';

/// App routes
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String editor = '/editor';
  static const String gallery = '/gallery';
  static const String galleryItem = '/gallery/:id';
  static const String paywall = '/paywall';
  static const String settings = '/settings';
}

/// App router configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editor,
      name: 'editor',
      pageBuilder: (context, state) {
        final initialImageBytes = state.extra as dynamic;
        return MaterialPage(
          key: state.pageKey,
          child: EditorScreen(initialImageBytes: initialImageBytes),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.gallery,
      name: 'gallery',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const GalleryScreen(),
      ),
      routes: [
        GoRoute(
          path: ':id',
          name: 'gallery-item',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return MaterialPage(
              key: state.pageKey,
              child: GalleryItemScreen(itemId: id),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.paywall,
      name: 'paywall',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const PaywallScreen(),
        fullscreenDialog: true,
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
