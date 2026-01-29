import 'clipboard_item_type.dart';

/// Represents a single clipboard capture.
///
/// See Memory 06: Data Models Specification.
///
/// Rules:
/// - Only one content field may be non-null (plainText, imagePath, or filePaths).
/// - Immutable after creation except: isPinned, tags, summary, language, category.
class ClipboardItem {
  /// Unique UUID identifier.
  final String id;

  /// The type of clipboard content.
  final ClipboardItemType type;

  /// Normalized plain text content (for text type).
  final String? plainText;

  /// Local cached image file path (for image type).
  final String? imagePath;

  /// Copied file paths (for files type).
  final List<String>? filePaths;

  /// Timestamp when this item was captured.
  final DateTime createdAt;

  /// Whether the user has pinned this item.
  final bool isPinned;

  /// AI-generated tags/keywords.
  final List<String> tags;

  /// AI-generated summary for long text.
  final String? summary;

  /// Detected language code.
  final String? language;

  /// AI-classified category.
  final String? category;

  const ClipboardItem({
    required this.id,
    required this.type,
    this.plainText,
    this.imagePath,
    this.filePaths,
    required this.createdAt,
    this.isPinned = false,
    this.tags = const [],
    this.summary,
    this.language,
    this.category,
  });

  /// Creates a copy with updated fields.
  ClipboardItem copyWith({
    String? id,
    ClipboardItemType? type,
    String? plainText,
    String? imagePath,
    List<String>? filePaths,
    DateTime? createdAt,
    bool? isPinned,
    List<String>? tags,
    String? summary,
    String? language,
    String? category,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      type: type ?? this.type,
      plainText: plainText ?? this.plainText,
      imagePath: imagePath ?? this.imagePath,
      filePaths: filePaths ?? this.filePaths,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      language: language ?? this.language,
      category: category ?? this.category,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'plainText': plainText,
      'imagePath': imagePath,
      'filePaths': filePaths,
      'createdAt': createdAt.toIso8601String(),
      'isPinned': isPinned,
      'tags': tags,
      'summary': summary,
      'language': language,
      'category': category,
    };
  }

  /// Deserializes from JSON map.
  factory ClipboardItem.fromJson(Map<String, dynamic> json) {
    return ClipboardItem(
      id: json['id'] as String,
      type: ClipboardItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ClipboardItemType.text,
      ),
      plainText: json['plainText'] as String?,
      imagePath: json['imagePath'] as String?,
      filePaths: (json['filePaths'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      summary: json['summary'] as String?,
      language: json['language'] as String?,
      category: json['category'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipboardItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ClipboardItem(id: $id, type: $type, createdAt: $createdAt)';
}
