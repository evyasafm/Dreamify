import 'package:equatable/equatable.dart';

/// Represents an item in the user's gallery
class GalleryItem extends Equatable {
  const GalleryItem({
    required this.id,
    required this.imageId,
    required this.thumbnailPath,
    required this.fullPath,
    required this.createdAt,
    this.prompt,
    this.tags = const [],
    this.collectionId,
    this.isFavorite = false,
  });

  final String id;
  final String imageId; // Links to ImageResult
  final String thumbnailPath;
  final String fullPath;
  final DateTime createdAt;
  final String? prompt;
  final List<String> tags;
  final String? collectionId;
  final bool isFavorite;

  GalleryItem copyWith({
    String? id,
    String? imageId,
    String? thumbnailPath,
    String? fullPath,
    DateTime? createdAt,
    String? prompt,
    List<String>? tags,
    String? collectionId,
    bool? isFavorite,
  }) {
    return GalleryItem(
      id: id ?? this.id,
      imageId: imageId ?? this.imageId,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fullPath: fullPath ?? this.fullPath,
      createdAt: createdAt ?? this.createdAt,
      prompt: prompt ?? this.prompt,
      tags: tags ?? this.tags,
      collectionId: collectionId ?? this.collectionId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Add a tag
  GalleryItem addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// Remove a tag
  GalleryItem removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// Toggle favorite status
  GalleryItem toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  @override
  List<Object?> get props => [
        id,
        imageId,
        thumbnailPath,
        fullPath,
        createdAt,
        prompt,
        tags,
        collectionId,
        isFavorite,
      ];
}

/// Collection of gallery items
class GalleryCollection extends Equatable {
  const GalleryCollection({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.coverImagePath,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String? description;
  final String? coverImagePath;

  GalleryCollection copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? description,
    String? coverImagePath,
  }) {
    return GalleryCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        description,
        coverImagePath,
      ];
}
