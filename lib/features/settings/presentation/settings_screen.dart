import 'package:flutter/material.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.diamond),
            title: const Text('Premium'),
            subtitle: const Text('Upgrade to unlock all features'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to paywall
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.photo_size_select_large),
            title: const Text('Default Quality'),
            subtitle: const Text('Standard (1024px)'),
            onTap: () {
              // TODO: Show quality selector
            },
          ),
          ListTile(
            leading: const Icon(Icons.aspect_ratio),
            title: const Text('Default Aspect Ratio'),
            subtitle: const Text('Square (1:1)'),
            onTap: () {
              // TODO: Show ratio selector
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {
              // TODO: Show language selector
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('System'),
            onTap: () {
              // TODO: Show theme selector
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Open terms
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              // TODO: Open support
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear Cache'),
            onTap: () {
              // TODO: Clear cache
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              // TODO: Sign out
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
