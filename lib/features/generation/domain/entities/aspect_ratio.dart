/// Supported aspect ratios for image generation
enum ImageAspectRatio {
  square('1:1', 1.0),
  portrait('4:5', 0.8),
  landscape('16:9', 1.78),
  vertical('9:16', 0.56);

  const ImageAspectRatio(this.label, this.value);

  final String label;
  final double value;

  /// Get width and height for a given base size
  ({int width, int height}) getDimensions(int baseSize) {
    switch (this) {
      case ImageAspectRatio.square:
        return (width: baseSize, height: baseSize);
      case ImageAspectRatio.portrait:
        return (width: (baseSize * 0.8).round(), height: baseSize);
      case ImageAspectRatio.landscape:
        return (width: baseSize, height: (baseSize / 1.78).round());
      case ImageAspectRatio.vertical:
        return (width: (baseSize * 0.56).round(), height: baseSize);
    }
  }
}
