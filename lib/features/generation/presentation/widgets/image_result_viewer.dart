import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/image_result.dart';

/// Widget to display image generation result
class ImageResultViewer extends StatelessWidget {
  const ImageResultViewer({
    super.key,
    this.result,
    required this.isGenerating,
    this.progress = 0.0,
  });

  final ImageResult? result;
  final bool isGenerating;
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (result == null && !isGenerating) {
      return _buildPlaceholder(context);
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image display
          if (result != null)
            Image.memory(
              result!.bytes,
              fit: BoxFit.contain,
            ),

          // Loading overlay
          if (isGenerating)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated painting effect
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary,
                      highlightColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(
                        Icons.brush,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Creating your masterpiece...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Your creation will appear here',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe what you want to see',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
