import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/services.dart';

/// SQLite implementation of ClipboardRepository.
///
/// Uses sqflite_common_ffi for desktop compatibility.
class SqliteClipboardRepository implements ClipboardRepository {
  static const String _tableName = 'clipboard_items';
  static const int _dbVersion = 1;

  Database? _database;

  /// Initializes the database connection.
  Future<void> initialize() async {
    if (_database != null) return;

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final appDir = await getApplicationSupportDirectory();
    final dbPath = '${appDir.path}/clipboard_brain.db';

    _database = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        plainText TEXT,
        imagePath TEXT,
        filePaths TEXT,
        createdAt TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        tags TEXT NOT NULL DEFAULT '[]',
        summary TEXT,
        language TEXT,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_createdAt ON $_tableName (createdAt DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_isPinned ON $_tableName (isPinned)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  Database get _db {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  @override
  Future<List<ClipboardItem>> getAll() async {
    final rows = await _db.query(_tableName, orderBy: 'createdAt DESC');
    return rows.map(_rowToItem).toList();
  }

  @override
  Future<ClipboardItem?> getById(String id) async {
    final rows = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToItem(rows.first);
  }

  @override
  Future<void> insert(ClipboardItem item) async {
    await _db.insert(
      _tableName,
      _itemToRow(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(ClipboardItem item) async {
    await _db.update(
      _tableName,
      _itemToRow(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> pruneOldItems(int maxItems) async {
    final currentCount = await count();
    if (currentCount <= maxItems) return;

    final toDelete = currentCount - maxItems;
    await _db.rawDelete(
      '''
      DELETE FROM $_tableName
      WHERE id IN (
        SELECT id FROM $_tableName
        WHERE isPinned = 0
        ORDER BY createdAt ASC
        LIMIT ?
      )
    ''',
      [toDelete],
    );
  }

  @override
  Future<List<ClipboardItem>> search(String query) async {
    if (query.trim().isEmpty) return getAll();

    final rows = await _db.query(
      _tableName,
      where: 'plainText LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return rows.map(_rowToItem).toList();
  }

  @override
  Future<int> count() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $_tableName',
    );
    return (result.first['cnt'] as int?) ?? 0;
  }

  /// Closes the database connection.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  ClipboardItem _rowToItem(Map<String, dynamic> row) {
    return ClipboardItem(
      id: row['id'] as String,
      type: ClipboardItemType.values.firstWhere(
        (e) => e.name == row['type'],
        orElse: () => ClipboardItemType.text,
      ),
      plainText: row['plainText'] as String?,
      imagePath: row['imagePath'] as String?,
      filePaths: row['filePaths'] != null
          ? (jsonDecode(row['filePaths'] as String) as List<dynamic>)
                .cast<String>()
          : null,
      createdAt: DateTime.parse(row['createdAt'] as String),
      isPinned: (row['isPinned'] as int) == 1,
      tags: (jsonDecode(row['tags'] as String) as List<dynamic>).cast<String>(),
      summary: row['summary'] as String?,
      language: row['language'] as String?,
      category: row['category'] as String?,
    );
  }

  Map<String, dynamic> _itemToRow(ClipboardItem item) {
    return {
      'id': item.id,
      'type': item.type.name,
      'plainText': item.plainText,
      'imagePath': item.imagePath,
      'filePaths': item.filePaths != null ? jsonEncode(item.filePaths) : null,
      'createdAt': item.createdAt.toIso8601String(),
      'isPinned': item.isPinned ? 1 : 0,
      'tags': jsonEncode(item.tags),
      'summary': item.summary,
      'language': item.language,
      'category': item.category,
    };
  }
}
