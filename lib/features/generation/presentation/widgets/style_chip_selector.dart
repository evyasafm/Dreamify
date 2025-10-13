import 'package:flutter/material.dart';

/// Widget for selecting style tags
class StyleChipSelector extends StatelessWidget {
  const StyleChipSelector({
    super.key,
    required this.styles,
    required this.selectedStyles,
    required this.onStylesChanged,
  });

  final List<String> styles;
  final List<String> selectedStyles;
  final ValueChanged<List<String>> onStylesChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: styles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = styles[index];
          final isSelected = selectedStyles.contains(style);

          return FilterChip(
            label: Text(style),
            selected: isSelected,
            onSelected: (selected) {
              final newStyles = List<String>.from(selectedStyles);
              if (selected) {
                newStyles.add(style);
              } else {
                newStyles.remove(style);
              }
              onStylesChanged(newStyles);
            },
          );
        },
      ),
    );
  }
}
