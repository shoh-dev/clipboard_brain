import '../entities/clipboard_item.dart';

/// Repository interface for clipboard item persistence.
///
/// Infrastructure implementations must implement this interface.
abstract class ClipboardRepository {
  /// Retrieves all clipboard items, ordered by createdAt descending.
  Future<List<ClipboardItem>> getAll();

  /// Retrieves a single item by ID.
  Future<ClipboardItem?> getById(String id);

  /// Inserts a new clipboard item.
  Future<void> insert(ClipboardItem item);

  /// Updates an existing clipboard item.
  Future<void> update(ClipboardItem item);

  /// Deletes an item by ID.
  Future<void> delete(String id);

  /// Deletes all items except pinned ones when count exceeds limit.
  Future<void> pruneOldItems(int maxItems);

  /// Searches items by plain text query (keyword search).
  Future<List<ClipboardItem>> search(String query);

  /// Returns the total count of items.
  Future<int> count();
}
