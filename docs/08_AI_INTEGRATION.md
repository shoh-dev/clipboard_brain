# Clipboard Brain — AI Integration Specification

## 1. Purpose of This Document

This document defines:

- How AI is used in the application.
- What AI is allowed to do.
- Which models are allowed.
- Performance and privacy constraints.
- Failure behavior.

Any AI behavior not explicitly described here is forbidden.

---

---

## 2. AI Goals (MVP)

AI is used ONLY for:

1. Generating tags for clipboard items.
2. Summarizing long text.
3. Detecting language.
4. Classifying content category.
5. Supporting semantic search ranking.

AI is NOT used for:

- Chat
- Content generation
- User conversations
- Automation
- Recommendations

---

---

## 3. AI Execution Constraints

- Must run fully on-device.
- Must NOT require network connectivity.
- Must NOT upload any user data.
- Must run asynchronously.
- Must allow disabling via Settings.

---

---

## 4. Approved AI Integration Options

### Primary

- `flutter_foundation_models_framework`

### Secondary (Fallback)

- Native Swift integration with Apple Foundation Models via Platform Channels.

The AI agent must attempt Primary first.

---

---

## 5. AI Service Architecture

```

UI
↓
ViewModel
↓
Domain (AIUseCase)
↓
Infrastructure (AIService)
↓
Foundation Model Plugin / Native

```

UI must never directly call AI APIs.

---

---

## 6. AI Input Rules

AI inputs must:

- Be sanitized.
- Truncated to safe limits.
- Never include binary data.
- Avoid extremely large prompts.

---

---

## 7. AI Output Schema

AIService must return:

```dart
class AIEnrichmentResult {
  final List<String> tags;
  final String? summary;
  final String? language;
  final String? category;
}
```

Fields may be null if unavailable.

---

---

## 8. Performance Limits

- AI processing per item should complete under 1 second typical.
- Must not block UI thread.
- Must batch processing when possible.

---

---

## 9. Caching Strategy

- AI results must be cached locally.
- Reprocessing same content should be avoided.
- Cache key must be deterministic.

---

---

## 10. Failure Behavior

If AI fails:

- Clipboard item must still be stored.
- AI fields remain null.
- Error must be logged silently.
- No user disruption.

---

---

## 11. User Controls

Settings must allow:

- Enable / disable AI processing.
- Clear AI cache.

---

---

## 12. Privacy Guarantees

- No AI telemetry.
- No analytics.
- No cloud inference.

---

---

## 13. Testing Rules

- AI service must be mockable.
- Deterministic fallback behavior.

---

---

## 14. Forbidden

❌ Network-based AI APIs
❌ Sending clipboard data externally
❌ Blocking synchronous inference
❌ Storing raw prompts unnecessarily
❌ Large model downloads at runtime

---

---

## 15. Change Policy

AI changes require approval.
