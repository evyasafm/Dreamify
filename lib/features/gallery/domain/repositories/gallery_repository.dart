import '../entities/gallery_item.dart';

/// Repository for managing gallery items
abstract class GalleryRepository {
  /// Get all gallery items
  Future<List<GalleryItem>> getAllItems();

  /// Get items by collection
  Future<List<GalleryItem>> getItemsByCollection(String collectionId);

  /// Get favorite items
  Future<List<GalleryItem>> getFavorites();

  /// Search items by query
  Future<List<GalleryItem>> searchItems(String query);

  /// Save a new item
  Future<void> saveItem(GalleryItem item);

  /// Update an existing item
  Future<void> updateItem(GalleryItem item);

  /// Delete an item
  Future<void> deleteItem(String id);

  /// Get all collections
  Future<List<GalleryCollection>> getCollections();

  /// Create a new collection
  Future<GalleryCollection> createCollection(String name, String? description);

  /// Delete a collection
  Future<void> deleteCollection(String id);

  /// Export item to device gallery
  Future<String> exportToDevice(String itemId);
}
