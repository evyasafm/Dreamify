import 'dart:io';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;
import '../domain/entities/gallery_item.dart';
import '../domain/repositories/gallery_repository.dart';

/// Local storage service using Hive
class LocalStorageService implements GalleryRepository {
  LocalStorageService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;
  late Box<Map<dynamic, dynamic>> _itemsBox;
  late Box<Map<dynamic, dynamic>> _collectionsBox;
  late String _imagesDir;
  late String _thumbnailsDir;

  static const String itemsBoxName = 'gallery_items';
  static const String collectionsBoxName = 'gallery_collections';
  static const int thumbnailSize = 300;

  /// Initialize storage
  Future<void> initialize() async {
    await Hive.initFlutter();

    _itemsBox = await Hive.openBox<Map<dynamic, dynamic>>(itemsBoxName);
    _collectionsBox = await Hive.openBox<Map<dynamic, dynamic>>(collectionsBoxName);

    final appDir = await getApplicationDocumentsDirectory();
    _imagesDir = '${appDir.path}/images';
    _thumbnailsDir = '${appDir.path}/thumbnails';

    await Directory(_imagesDir).create(recursive: true);
    await Directory(_thumbnailsDir).create(recursive: true);

    _logger.i('Local storage initialized');
  }

  @override
  Future<List<GalleryItem>> getAllItems() async {
    try {
      final items = _itemsBox.values
          .map((data) => _mapToGalleryItem(Map<String, dynamic>.from(data)))
          .toList();

      // Sort by creation date, newest first
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return items;
    } catch (e) {
      _logger.e('Error getting all items', error: e);
      return [];
    }
  }

  @override
  Future<List<GalleryItem>> getItemsByCollection(String collectionId) async {
    try {
      final items = await getAllItems();
      return items.where((item) => item.collectionId == collectionId).toList();
    } catch (e) {
      _logger.e('Error getting items by collection', error: e);
      return [];
    }
  }

  @override
  Future<List<GalleryItem>> getFavorites() async {
    try {
      final items = await getAllItems();
      return items.where((item) => item.isFavorite).toList();
    } catch (e) {
      _logger.e('Error getting favorites', error: e);
      return [];
    }
  }

  @override
  Future<List<GalleryItem>> searchItems(String query) async {
    try {
      final items = await getAllItems();
      final lowercaseQuery = query.toLowerCase();

      return items.where((item) {
        final promptMatch = item.prompt?.toLowerCase().contains(lowercaseQuery) ?? false;
        final tagMatch = item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
        return promptMatch || tagMatch;
      }).toList();
    } catch (e) {
      _logger.e('Error searching items', error: e);
      return [];
    }
  }

  @override
  Future<void> saveItem(GalleryItem item) async {
    try {
      await _itemsBox.put(item.id, _mapToJson(item));
      _logger.i('Item saved: ${item.id}');
    } catch (e) {
      _logger.e('Error saving item', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateItem(GalleryItem item) async {
    try {
      await _itemsBox.put(item.id, _mapToJson(item));
      _logger.i('Item updated: ${item.id}');
    } catch (e) {
      _logger.e('Error updating item', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      final item = _itemsBox.get(id);
      if (item != null) {
        final galleryItem = _mapToGalleryItem(Map<String, dynamic>.from(item));

        // Delete files
        await _deleteFile(galleryItem.fullPath);
        await _deleteFile(galleryItem.thumbnailPath);
      }

      await _itemsBox.delete(id);
      _logger.i('Item deleted: $id');
    } catch (e) {
      _logger.e('Error deleting item', error: e);
      rethrow;
    }
  }

  @override
  Future<List<GalleryCollection>> getCollections() async {
    try {
      final collections = _collectionsBox.values
          .map((data) => _mapToGalleryCollection(Map<String, dynamic>.from(data)))
          .toList();

      collections.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return collections;
    } catch (e) {
      _logger.e('Error getting collections', error: e);
      return [];
    }
  }

  @override
  Future<GalleryCollection> createCollection(String name, String? description) async {
    try {
      final collection = GalleryCollection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
        description: description,
      );

      await _collectionsBox.put(collection.id, _mapCollectionToJson(collection));
      _logger.i('Collection created: ${collection.id}');

      return collection;
    } catch (e) {
      _logger.e('Error creating collection', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    try {
      // Remove collection reference from all items
      final items = await getItemsByCollection(id);
      for (final item in items) {
        await updateItem(item.copyWith(collectionId: null));
      }

      await _collectionsBox.delete(id);
      _logger.i('Collection deleted: $id');
    } catch (e) {
      _logger.e('Error deleting collection', error: e);
      rethrow;
    }
  }

  @override
  Future<String> exportToDevice(String itemId) async {
    try {
      final itemData = _itemsBox.get(itemId);
      if (itemData == null) {
        throw Exception('Item not found');
      }

      final item = _mapToGalleryItem(Map<String, dynamic>.from(itemData));

      // In a real implementation, this would save to the device's gallery
      // using photo_manager or similar package
      _logger.i('Item exported: $itemId');

      return item.fullPath;
    } catch (e) {
      _logger.e('Error exporting item', error: e);
      rethrow;
    }
  }

  /// Save image file and create thumbnail
  Future<({String fullPath, String thumbnailPath})> saveImageFile(
    String id,
    Uint8List imageBytes,
  ) async {
    try {
      final fullPath = '$_imagesDir/$id.png';
      final thumbnailPath = '$_thumbnailsDir/$id.png';

      // Save full image
      await File(fullPath).writeAsBytes(imageBytes);

      // Create and save thumbnail
      final image = img.decodeImage(imageBytes);
      if (image != null) {
        final thumbnail = img.copyResize(
          image,
          width: thumbnailSize,
          height: (thumbnailSize * image.height / image.width).round(),
        );
        await File(thumbnailPath).writeAsBytes(img.encodePng(thumbnail));
      }

      _logger.i('Image saved: $id');
      return (fullPath: fullPath, thumbnailPath: thumbnailPath);
    } catch (e) {
      _logger.e('Error saving image file', error: e);
      rethrow;
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      _logger.w('Error deleting file: $path', error: e);
    }
  }

  // Mapping methods

  GalleryItem _mapToGalleryItem(Map<String, dynamic> data) {
    return GalleryItem(
      id: data['id'] as String,
      imageId: data['imageId'] as String,
      thumbnailPath: data['thumbnailPath'] as String,
      fullPath: data['fullPath'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      prompt: data['prompt'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      collectionId: data['collectionId'] as String?,
      isFavorite: data['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _mapToJson(GalleryItem item) {
    return {
      'id': item.id,
      'imageId': item.imageId,
      'thumbnailPath': item.thumbnailPath,
      'fullPath': item.fullPath,
      'createdAt': item.createdAt.toIso8601String(),
      'prompt': item.prompt,
      'tags': item.tags,
      'collectionId': item.collectionId,
      'isFavorite': item.isFavorite,
    };
  }

  GalleryCollection _mapToGalleryCollection(Map<String, dynamic> data) {
    return GalleryCollection(
      id: data['id'] as String,
      name: data['name'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      description: data['description'] as String?,
      coverImagePath: data['coverImagePath'] as String?,
    );
  }

  Map<String, dynamic> _mapCollectionToJson(GalleryCollection collection) {
    return {
      'id': collection.id,
      'name': collection.name,
      'createdAt': collection.createdAt.toIso8601String(),
      'description': collection.description,
      'coverImagePath': collection.coverImagePath,
    };
  }

  /// Close storage
  Future<void> close() async {
    await _itemsBox.close();
    await _collectionsBox.close();
  }
}
