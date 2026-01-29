import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/services.dart';
import '../../infrastructure/ai/ai_service.dart';
import '../../infrastructure/native_bridge/native_bridge_service.dart';

/// ViewModel for clipboard history management.
///
/// Coordinates between native clipboard events, persistence,
/// and UI state. Follows Memory 05: State Management Specification.
class ClipboardViewModel extends ChangeNotifier {
  final ClipboardRepository _repository;
  final NativeBridgeService _nativeBridge;
  final AIService _aiService;
  final Uuid _uuid = const Uuid();

  // Private state
  List<ClipboardItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  ClipboardItem? _selectedItem;
  StreamSubscription<dynamic>? _clipboardSubscription;

  // Public getters (immutable views)
  List<ClipboardItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ClipboardItem? get selectedItem => _selectedItem;

  /// Maximum number of items to keep in history.
  final int maxHistoryItems;

  ClipboardViewModel({
    required ClipboardRepository repository,
    required NativeBridgeService nativeBridge,
    required AIService aiService,
    this.maxHistoryItems = 2000,
  }) : _repository = repository,
       _nativeBridge = nativeBridge,
       _aiService = aiService;

  /// Initializes the ViewModel and starts clipboard monitoring.
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadItems();
      await _startClipboardMonitoring();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadItems() async {
    if (_searchQuery.isEmpty) {
      _items = await _repository.getAll();
    } else {
      _items = await _repository.search(_searchQuery);
    }
    notifyListeners();
  }

  Future<void> _startClipboardMonitoring() async {
    await _nativeBridge.startClipboardListener();

    _clipboardSubscription = _nativeBridge.clipboardEvents.listen(
      _handleClipboardEvent,
      onError: (error) {
        _errorMessage = 'Clipboard monitoring error: $error';
        notifyListeners();
      },
    );
  }

  void _handleClipboardEvent(dynamic event) {
    if (event is! Map) return;

    final Map<String, dynamic> data = Map<String, dynamic>.from(event);
    final type = _parseType(data['type'] as String?);
    final text = data['text'] as String?;
    final imagePath = data['imagePath'] as String?;
    final filePaths = (data['filePaths'] as List<dynamic>?)?.cast<String>();
    final timestamp = data['timestamp'] as String?;

    // Skip empty clipboard events
    if (type == ClipboardItemType.text && (text == null || text.isEmpty)) {
      return;
    }

    // Avoid duplicates (check last item)
    if (_items.isNotEmpty) {
      final last = _items.first;
      if (last.type == type &&
          last.plainText == text &&
          last.imagePath == imagePath) {
        return;
      }
    }

    final item = ClipboardItem(
      id: _uuid.v4(),
      type: type,
      plainText: text,
      imagePath: imagePath,
      filePaths: filePaths,
      createdAt: timestamp != null ? DateTime.parse(timestamp) : DateTime.now(),
    );

    _saveItemWithAI(item);
  }

  ClipboardItemType _parseType(String? type) {
    switch (type) {
      case 'image':
        return ClipboardItemType.image;
      case 'files':
        return ClipboardItemType.files;
      default:
        return ClipboardItemType.text;
    }
  }

  Future<void> _saveItemWithAI(ClipboardItem item) async {
    try {
      // Enrich text items with AI
      ClipboardItem enrichedItem = item;
      if (item.type == ClipboardItemType.text && item.plainText != null) {
        final enrichment = await _aiService.enrichText(item.plainText!);
        enrichedItem = item.copyWith(
          tags: enrichment.tags,
          summary: enrichment.summary,
          language: enrichment.language,
          category: enrichment.category,
        );
      }

      await _repository.insert(enrichedItem);
      await _repository.pruneOldItems(maxHistoryItems);
      await _loadItems();

      // Auto-select new item if none selected
      if (_selectedItem == null && _items.isNotEmpty) {
        _selectedItem = _items.first;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to save clipboard item: $e';
      notifyListeners();
    }
  }

  // MARK: - Public Commands

  /// Updates the search query and filters items.
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await _loadItems();
  }

  /// Selects an item for preview.
  void selectItem(ClipboardItem? item) {
    _selectedItem = item;
    notifyListeners();
  }

  /// Toggles pin status of an item.
  Future<void> togglePin(ClipboardItem item) async {
    final updated = item.copyWith(isPinned: !item.isPinned);
    await _repository.update(updated);
    await _loadItems();

    if (_selectedItem?.id == item.id) {
      _selectedItem = updated;
      notifyListeners();
    }
  }

  /// Deletes an item.
  Future<void> deleteItem(ClipboardItem item) async {
    await _repository.delete(item.id);

    if (_selectedItem?.id == item.id) {
      _selectedItem = null;
    }

    await _loadItems();
  }

  /// Refreshes the item list from database.
  Future<void> refresh() async {
    _setLoading(true);
    try {
      await _loadItems();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _clipboardSubscription?.cancel();
    _nativeBridge.stopClipboardListener();
    super.dispose();
  }
}
