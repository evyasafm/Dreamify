import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Custom prompt input field with character counter
class PromptInputField extends StatelessWidget {
  const PromptInputField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLength: AppConstants.maxPromptLength,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Describe what you want to create...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: enabled ? onSubmitted : null,
        ),
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
