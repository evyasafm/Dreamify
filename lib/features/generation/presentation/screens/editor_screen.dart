import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../application/notifiers/editor_notifier.dart';
import '../../domain/entities/aspect_ratio.dart';
import '../../domain/entities/prompt.dart';
import '../widgets/image_result_viewer.dart';
import '../widgets/version_history_timeline.dart';
import '../widgets/style_chip_selector.dart';
import '../widgets/prompt_input_field.dart';

/// Main editor screen for generation and editing
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({
    super.key,
    this.initialImageBytes,
  });

  final Uint8List? initialImageBytes;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<String> _selectedStyles = [];
  ImageAspectRatio _selectedRatio = ImageAspectRatio.square;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImageBytes != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(editorNotifierProvider.notifier)
            .setInitialImage(widget.initialImageBytes!);
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create & Edit'),
        actions: [
          // History toggle
          if (editorState.hasHistory)
            IconButton(
              icon: Icon(_showHistory ? Icons.close : Icons.history),
              onPressed: () => setState(() => _showHistory = !_showHistory),
            ),
          // Save button
          if (editorState.hasResult)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveResult,
            ),
          // Share button
          if (editorState.hasResult)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResult,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Image result viewer
              Expanded(
                flex: 3,
                child: ImageResultViewer(
                  result: editorState.currentResult,
                  isGenerating: editorState.isGenerating,
                  progress: editorState.progress,
                ),
              ),

              // Controls section
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Quick action chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.quickPrompts.map((prompt) {
                          return ActionChip(
                            label: Text(prompt),
                            onPressed: () {
                              _promptController.text = prompt;
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Style selector
                      const Text('Style:'),
                      const SizedBox(height: 8),
                      StyleChipSelector(
                        styles: AppConstants.stylePresets,
                        selectedStyles: _selectedStyles,
                        onStylesChanged: (styles) {
                          setState(() => _selectedStyles
                            ..clear()
                            ..addAll(styles));
                        },
                      ),
                      const SizedBox(height: 16),

                      // Aspect ratio selector
                      Row(
                        children: [
                          const Text('Ratio:'),
                          const SizedBox(width: 16),
                          ...ImageAspectRatio.values.map((ratio) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(ratio.label),
                                selected: _selectedRatio == ratio,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedRatio = ratio);
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Prompt input
                      PromptInputField(
                        controller: _promptController,
                        enabled: !editorState.isGenerating,
                        onSubmitted: _handleGenerate,
                      ),
                      const SizedBox(height: 16),

                      // Generate button
                      ElevatedButton(
                        onPressed: editorState.isGenerating
                            ? null
                            : _handleGenerate,
                        child: Text(
                          editorState.hasResult
                              ? editorState.isGenerating
                                  ? 'Editing...'
                                  : 'Edit Image'
                              : editorState.isGenerating
                                  ? 'Generating...'
                                  : 'Generate',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // History timeline overlay
          if (_showHistory && editorState.hasHistory)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: VersionHistoryTimeline(
                history: editorState.history,
                currentId: editorState.currentResult?.id,
                onVersionSelected: (imageId) {
                  ref
                      .read(editorNotifierProvider.notifier)
                      .undoToVersion(imageId);
                  setState(() => _showHistory = false);
                },
              ),
            ),

          // Error display
          if (editorState.error != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          editorState.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          ref
                              .read(editorNotifierProvider.notifier)
                              .clearError();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleGenerate() {
    final promptText = _promptController.text.trim();
    if (promptText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    final prompt = Prompt(
      text: promptText,
      styleTags: _selectedStyles,
      aspectRatio: _selectedRatio,
    );

    final editorState = ref.read(editorNotifierProvider);
    if (editorState.hasResult) {
      ref.read(editorNotifierProvider.notifier).editImage(prompt);
    } else {
      ref.read(editorNotifierProvider.notifier).generateFromText(prompt);
    }
  }

  void _saveResult() {
    // TODO: Implement save to gallery
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to gallery')),
    );
  }

  void _shareResult() {
    // TODO: Implement share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }
}
