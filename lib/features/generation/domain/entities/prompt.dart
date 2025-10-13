import 'package:equatable/equatable.dart';
import 'aspect_ratio.dart';

/// Represents a user's generation prompt with configuration
class Prompt extends Equatable {
  const Prompt({
    required this.text,
    this.styleTags = const [],
    this.aspectRatio = ImageAspectRatio.square,
    this.quality = ImageQuality.standard,
    this.seed,
  });

  final String text;
  final List<String> styleTags;
  final ImageAspectRatio aspectRatio;
  final ImageQuality quality;
  final int? seed;

  /// Create a copy with modifications
  Prompt copyWith({
    String? text,
    List<String>? styleTags,
    ImageAspectRatio? aspectRatio,
    ImageQuality? quality,
    int? seed,
  }) {
    return Prompt(
      text: text ?? this.text,
      styleTags: styleTags ?? this.styleTags,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      quality: quality ?? this.quality,
      seed: seed ?? this.seed,
    );
  }

  /// Add a style tag
  Prompt addStyleTag(String tag) {
    return copyWith(styleTags: [...styleTags, tag]);
  }

  /// Remove a style tag
  Prompt removeStyleTag(String tag) {
    return copyWith(styleTags: styleTags.where((t) => t != tag).toList());
  }

  @override
  List<Object?> get props => [text, styleTags, aspectRatio, quality, seed];
}

/// Quality levels for generation
enum ImageQuality {
  standard(1024, 'Standard'),
  high(1536, 'High (Premium)'),
  ultra(2048, 'Ultra (Premium)');

  const ImageQuality(this.resolution, this.label);

  final int resolution;
  final String label;

  bool get isPremium => this != ImageQuality.standard;
}
