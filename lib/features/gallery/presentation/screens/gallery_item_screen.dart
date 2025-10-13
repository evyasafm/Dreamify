import 'package:flutter/material.dart';

/// Detail screen for a gallery item
class GalleryItemScreen extends StatelessWidget {
  const GalleryItemScreen({
    super.key,
    required this.itemId,
  });

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: Implement delete
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Gallery Item: $itemId'),
      ),
    );
  }
}
