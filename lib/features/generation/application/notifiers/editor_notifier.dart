import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../di/providers.dart';
import '../../domain/entities/prompt.dart';
import '../../domain/entities/image_result.dart';
import '../../domain/repositories/image_generation_repository.dart';
import 'editor_state.dart';

/// Notifier for managing editor state and generation operations
class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier({
    required this.repository,
  }) : super(const EditorState());

  final ImageGenerationRepository repository;
  CancelToken? _cancelToken;

  /// Generate image from text prompt
  Future<void> generateFromText(Prompt prompt) async {
    if (state.isGenerating) return;

    state = state.copyWith(
      isGenerating: true,
      progress: 0.1,
      error: null,
      currentPrompt: prompt,
    );

    _cancelToken = CancelToken();

    try {
      final result = await repository.generateFromText(
        prompt,
        cancelToken: _cancelToken,
      );

      // Add to history
      final newHistory = [...state.history, result];

      state = state.copyWith(
        currentResult: result,
        history: newHistory,
        isGenerating: false,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        progress: 0.0,
      );
    } finally {
      _cancelToken = null;
    }
  }

  /// Edit current image
  Future<void> editImage(Prompt prompt) async {
    if (state.isGenerating || state.currentResult == null) return;

    state = state.copyWith(
      isGenerating: true,
      progress: 0.1,
      error: null,
      currentPrompt: prompt,
    );

    _cancelToken = CancelToken();

    try {
      final result = await repository.editImage(
        state.currentResult!.bytes,
        prompt,
        cancelToken: _cancelToken,
      );

      // Add to history with parent reference
      final resultWithParent = result.copyWith(
        parentId: state.currentResult!.id,
      );
      final newHistory = [...state.history, resultWithParent];

      state = state.copyWith(
        currentResult: resultWithParent,
        history: newHistory,
        isGenerating: false,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        progress: 0.0,
      );
    } finally {
      _cancelToken = null;
    }
  }

  /// Compose multiple images
  Future<void> composeImages(List<Uint8List> images, Prompt prompt) async {
    if (state.isGenerating || images.isEmpty) return;

    state = state.copyWith(
      isGenerating: true,
      progress: 0.1,
      error: null,
      currentPrompt: prompt,
    );

    _cancelToken = CancelToken();

    try {
      final result = await repository.composeImages(
        images,
        prompt,
        cancelToken: _cancelToken,
      );

      final newHistory = [...state.history, result];

      state = state.copyWith(
        currentResult: result,
        history: newHistory,
        isGenerating: false,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        progress: 0.0,
      );
    } finally {
      _cancelToken = null;
    }
  }

  /// Undo to previous version
  void undoToVersion(String imageId) {
    final version = state.history.firstWhere(
      (img) => img.id == imageId,
      orElse: () => state.history.first,
    );

    state = state.copyWith(currentResult: version);
  }

  /// Cancel current generation
  void cancelGeneration() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('User cancelled');
      state = state.copyWith(
        isGenerating: false,
        error: 'Generation cancelled',
        progress: 0.0,
      );
    }
  }

  /// Clear current session
  void clearSession() {
    state = const EditorState();
  }

  /// Set initial image (from camera/gallery)
  void setInitialImage(Uint8List imageBytes) {
    // Create a placeholder result for the initial image
    final result = ImageResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bytes: imageBytes,
      createdAt: DateTime.now(),
      meta: {'type': 'initial'},
    );

    state = state.copyWith(
      currentResult: result,
      history: [result],
    );
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }
}

/// Provider for EditorNotifier
final editorNotifierProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier(
    repository: ref.watch(imageGenerationRepositoryProvider),
  );
});
