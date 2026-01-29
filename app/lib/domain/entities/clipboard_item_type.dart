/// Represents the type of clipboard content.
///
/// See Memory 06: Data Models Specification.
enum ClipboardItemType {
  /// Plain text content.
  text,

  /// Image content (stored as file path).
  image,

  /// File references (list of file paths).
  files,
}
