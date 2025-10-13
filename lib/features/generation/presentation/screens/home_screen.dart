import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routing/app_router.dart';

/// Home screen with main actions
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dreamify',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: () => context.push(AppRoutes.gallery),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => context.push(AppRoutes.settings),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Welcome Message
              Text(
                'What would you like to create today?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Main Actions
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Upload/Camera Action
                    _ActionCard(
                      icon: Icons.camera_alt,
                      title: 'Take Photo or Upload',
                      subtitle: 'Start with an existing image',
                      onTap: () => _pickImage(context),
                    ),
                    const SizedBox(height: 16),

                    // Text Prompt Action
                    _ActionCard(
                      icon: Icons.edit,
                      title: 'Describe Your Idea',
                      subtitle: 'Create from text description',
                      onTap: () => context.push(AppRoutes.editor),
                    ),
                    const SizedBox(height: 16),

                    // Compose Action
                    _ActionCard(
                      icon: Icons.collections,
                      title: 'Combine Images',
                      subtitle: 'Blend multiple images together',
                      onTap: () => _composeImages(context),
                    ),
                  ],
                ),
              ),

              // Inspiration Section
              Text(
                'Need inspiration?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _InspirationCard(
                      imageUrl: 'https://via.placeholder.com/150',
                      prompt: 'Cyberpunk city at night',
                      onTap: () => context.push(AppRoutes.editor),
                    ),
                    _InspirationCard(
                      imageUrl: 'https://via.placeholder.com/150',
                      prompt: 'Fantasy forest landscape',
                      onTap: () => context.push(AppRoutes.editor),
                    ),
                    _InspirationCard(
                      imageUrl: 'https://via.placeholder.com/150',
                      prompt: 'Minimalist abstract art',
                      onTap: () => context.push(AppRoutes.editor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      final image = await picker.pickImage(source: result);
      if (image != null && context.mounted) {
        final bytes = await image.readAsBytes();
        context.push(AppRoutes.editor, extra: bytes);
      }
    }
  }

  Future<void> _composeImages(BuildContext context) async {
    // TODO: Implement multi-image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Multi-image composition coming soon!')),
    );
  }
}

/// Action card widget
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inspiration card widget
class _InspirationCard extends StatelessWidget {
  const _InspirationCard({
    required this.imageUrl,
    required this.prompt,
    required this.onTap,
  });

  final String imageUrl;
  final String prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 150,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 80,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Icon(Icons.image),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prompt,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
