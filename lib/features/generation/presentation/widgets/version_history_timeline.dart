import 'package:flutter/material.dart';
import '../../domain/entities/image_result.dart';

/// Timeline widget showing version history
class VersionHistoryTimeline extends StatelessWidget {
  const VersionHistoryTimeline({
    super.key,
    required this.history,
    this.currentId,
    required this.onVersionSelected,
  });

  final List<ImageResult> history;
  final String? currentId;
  final ValueChanged<String> onVersionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final result = history[history.length - 1 - index];
                final isCurrent = result.id == currentId;

                return InkWell(
                  onTap: () => onVersionSelected(result.id),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.memory(
                            result.bytes,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'v${history.length - index}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
