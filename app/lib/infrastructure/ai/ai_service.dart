/// AI enrichment result containing generated tags and metadata.
///
/// See Memory 08: AI Integration Specification.
class AIEnrichmentResult {
  /// AI-generated keywords/tags.
  final List<String> tags;

  /// AI-generated summary for long text.
  final String? summary;

  /// Detected language code (e.g., 'en', 'ja').
  final String? language;

  /// AI-classified category.
  final String? category;

  const AIEnrichmentResult({
    this.tags = const [],
    this.summary,
    this.language,
    this.category,
  });
}

/// Service for on-device AI enrichment of clipboard items.
///
/// This is a stub implementation. Real implementation would use
/// Apple Foundation Models or similar on-device AI.
///
/// See Memory 08: AI Integration Specification.
abstract class AIService {
  /// Enriches clipboard text content with AI-generated metadata.
  Future<AIEnrichmentResult> enrichText(String text);

  /// Returns whether AI is available on this device.
  Future<bool> isAvailable();
}

/// Stub implementation of AIService for development.
///
/// Provides basic keyword extraction without actual AI.
class StubAIService implements AIService {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<AIEnrichmentResult> enrichText(String text) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 50));

    final tags = _extractKeywords(text);
    final language = _detectLanguage(text);
    final category = _classifyContent(text);
    final summary = text.length > 200 ? _generateSummary(text) : null;

    return AIEnrichmentResult(
      tags: tags,
      summary: summary,
      language: language,
      category: category,
    );
  }

  List<String> _extractKeywords(String text) {
    // Simple keyword extraction: find common patterns
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .toSet()
        .take(5)
        .toList();
    return words;
  }

  String _detectLanguage(String text) {
    // Very basic detection based on character ranges
    final hasJapanese = RegExp(r'[\u3040-\u309F\u30A0-\u30FF]').hasMatch(text);
    final hasKorean = RegExp(r'[\uAC00-\uD7AF]').hasMatch(text);
    final hasChinese = RegExp(r'[\u4E00-\u9FFF]').hasMatch(text);

    if (hasJapanese) return 'ja';
    if (hasKorean) return 'ko';
    if (hasChinese) return 'zh';
    return 'en';
  }

  String _classifyContent(String text) {
    final lower = text.toLowerCase();

    if (RegExp(r'https?://').hasMatch(lower)) return 'url';
    if (RegExp(r'[\w.]+@[\w.]+\.\w+').hasMatch(lower)) return 'email';
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(lower)) {
      return 'ip_address';
    }
    if (RegExp(
      r'(function|class|def|const|let|var|import|export)',
    ).hasMatch(lower)) {
      return 'code';
    }
    if (RegExp(r'^\s*[-*]\s').hasMatch(lower)) return 'list';
    if (text.split('\n').length > 5) return 'multiline';

    return 'text';
  }

  String _generateSummary(String text) {
    // Simple truncation-based summary
    final firstLine = text.split('\n').first;
    if (firstLine.length <= 100) return firstLine;
    return '${firstLine.substring(0, 97)}...';
  }
}
