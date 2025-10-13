import 'package:equatable/equatable.dart';
import '../../domain/entities/image_result.dart';
import '../../domain/entities/prompt.dart';

/// State for the editor screen
class EditorState extends Equatable {
  const EditorState({
    this.currentResult,
    this.history = const [],
    this.isGenerating = false,
    this.progress = 0.0,
    this.error,
    this.currentPrompt,
  });

  final ImageResult? currentResult;
  final List<ImageResult> history;
  final bool isGenerating;
  final double progress;
  final String? error;
  final Prompt? currentPrompt;

  bool get hasResult => currentResult != null;
  bool get hasHistory => history.isNotEmpty;
  bool get canUndo => history.length > 1;

  EditorState copyWith({
    ImageResult? currentResult,
    List<ImageResult>? history,
    bool? isGenerating,
    double? progress,
    String? error,
    Prompt? currentPrompt,
  }) {
    return EditorState(
      currentResult: currentResult ?? this.currentResult,
      history: history ?? this.history,
      isGenerating: isGenerating ?? this.isGenerating,
      progress: progress ?? this.progress,
      error: error,
      currentPrompt: currentPrompt ?? this.currentPrompt,
    );
  }

  EditorState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [
        currentResult,
        history,
        isGenerating,
        progress,
        error,
        currentPrompt,
      ];
}
