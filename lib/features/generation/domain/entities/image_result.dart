import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Represents a generated or edited image result
class ImageResult extends Equatable {
  const ImageResult({
    required this.id,
    required this.bytes,
    required this.createdAt,
    this.parentId,
    this.meta = const {},
    this.localPath,
    this.thumbnailPath,
  });

  final String id;
  final Uint8List bytes;
  final DateTime createdAt;
  final String? parentId; // For tracking refinement history
  final Map<String, dynamic> meta; // Stores prompt, duration, cost, etc.
  final String? localPath;
  final String? thumbnailPath;

  /// Extract metadata helpers
  String? get prompt => meta['prompt'] as String?;
  int? get creditCost => meta['creditCost'] as int?;
  int? get durationMs => meta['durationMs'] as int?;
  String? get aspectRatio => meta['aspectRatio'] as String?;
  bool get hasWatermark => meta['hasWatermark'] as bool? ?? false;

  /// Create a copy with modifications
  ImageResult copyWith({
    String? id,
    Uint8List? bytes,
    DateTime? createdAt,
    String? parentId,
    Map<String, dynamic>? meta,
    String? localPath,
    String? thumbnailPath,
  }) {
    return ImageResult(
      id: id ?? this.id,
      bytes: bytes ?? this.bytes,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      meta: meta ?? this.meta,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Check if this is a root generation (no parent)
  bool get isRoot => parentId == null;

  @override
  List<Object?> get props => [
        id,
        bytes,
        createdAt,
        parentId,
        meta,
        localPath,
        thumbnailPath,
      ];
}

/// Represents a generation job in progress
class GenerationJob extends Equatable {
  const GenerationJob({
    required this.id,
    required this.prompt,
    required this.status,
    required this.createdAt,
    this.progress = 0.0,
    this.errorMessage,
    this.result,
  });

  final String id;
  final String prompt;
  final JobStatus status;
  final DateTime createdAt;
  final double progress;
  final String? errorMessage;
  final ImageResult? result;

  bool get isCompleted => status == JobStatus.completed;
  bool get isFailed => status == JobStatus.failed;
  bool get isProcessing => status == JobStatus.processing;
  bool get isPending => status == JobStatus.pending;

  GenerationJob copyWith({
    String? id,
    String? prompt,
    JobStatus? status,
    DateTime? createdAt,
    double? progress,
    String? errorMessage,
    ImageResult? result,
  }) {
    return GenerationJob(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        id,
        prompt,
        status,
        createdAt,
        progress,
        errorMessage,
        result,
      ];
}

enum JobStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}
