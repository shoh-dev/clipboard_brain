import 'dart:convert';
import 'package:foundation_models_framework/foundation_models_framework.dart';

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
/// See Memory 08: AI Integration Specification.
abstract class AIService {
  /// Enriches clipboard text content with AI-generated metadata.
  Future<AIEnrichmentResult> enrichText(String text);

  /// Returns whether AI is available on this device.
  Future<bool> isAvailable();
}

/// Implementation of AIService using Apple Foundation Models.
class FoundationModelsAIService implements AIService {
  final _fm = FoundationModelsFramework.instance;

  @override
  Future<bool> isAvailable() async {
    try {
      final availability = await _fm.checkAvailability();
      return availability.isAvailable;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AIEnrichmentResult> enrichText(String text) async {
    // Sanitize and limit input length for safety
    final sanitizedText = text.length > 2000 ? text.substring(0, 2000) : text;

    final prompt =
        """
Analyze the following clipboard snippet and provide metadata in JSON format.
Include:
- tags: Array of up to 5 keywords.
- summary: A concise one-line summary.
- language: ISO 639-1 code.
- category: One of [text, code, url, email, ip_address, list].

Response MUST be valid JSON only.

Snippet:
$sanitizedText
""";

    try {
      final response = await _fm.sendPrompt(
        prompt,
        instructions:
            "You are a metadata extraction tool. Always respond in valid JSON.",
        options: GenerationOptionsRequest(
          temperature: 0.1,
          maximumResponseTokens: 300,
        ),
      );

      if (response.errorMessage != null) {
        return const AIEnrichmentResult();
      }

      // Find JSON block in response
      final jsonMatch = RegExp(
        r'\{.*\}',
        dotAll: true,
      ).firstMatch(response.content);
      if (jsonMatch == null) return const AIEnrichmentResult();

      final data = jsonDecode(jsonMatch.group(0)!);

      return AIEnrichmentResult(
        tags: (data['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        summary: data['summary']?.toString(),
        language: data['language']?.toString(),
        category: data['category']?.toString(),
      );
    } catch (e) {
      // Fallback if AI fails
      return const AIEnrichmentResult();
    }
  }
}
