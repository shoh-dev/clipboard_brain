# Clipboard Brain — Testing Strategy

## 1. Purpose of This Document

This document defines:

- What must be tested.
- How tests are structured.
- Which tools are allowed.
- Quality gates before acceptance.

All production code must comply with this strategy.

---

---

## 2. Testing Levels

### 2.1 Unit Tests (Primary)

Focus:

- Domain logic
- ViewModels
- Validation rules
- State transitions

Target Coverage:

- ≥80% for domain and ViewModels

---

---

### 2.2 Integration Tests (Secondary)

Focus:

- Database persistence
- AI service mocking
- Native bridge mocking

---

---

### 2.3 UI Tests (Optional MVP)

Focus:

- Critical flows only
- Smoke tests

---

---

## 3. Tooling

### Approved

- flutter_test
- mocktail (for mocking)
- test

### Forbidden

❌ Mockito  
❌ Golden tests  
❌ Snapshot tests  
❌ End-to-end automation frameworks

---

---

## 4. Test Folder Structure

```

test/
├── domain/
├── view_models/
├── infrastructure/
└── helpers/

```

Structure must mirror lib/.

---

---

## 5. Naming Rules

- Test files must end with `_test.dart`.
- Test descriptions must be explicit.

Example:

```dart
test('SearchService returns ranked results for semantic query');
```

---

---

## 6. What Must Be Tested

### Domain

- Filtering logic
- Ranking algorithms
- Validation rules

---

### ViewModels

- Loading states
- Error handling
- State mutation correctness
- Disposal behavior

---

### Infrastructure

- Serialization
- Repository behavior
- Error mapping

Native code is manually tested.

---

---

## 7. Mocking Rules

- Mock only interfaces.
- Never mock concrete classes.
- Avoid over-mocking.

---

---

## 8. Determinism Rules

- No random values in tests.
- No time dependency.
- Use fake clocks if needed.

---

---

## 9. Performance Tests (Optional)

- Search under 200ms for 5k items.
- Memory stability.

---

---

## 10. Test Execution

Run all tests:

```bash
flutter test
```

---

---

## 11. Quality Gates

Before merge:

- All tests pass.
- No skipped tests.
- No failing analyzer warnings.
- Lint clean.

---

---

## 12. Forbidden

❌ Skipping tests
❌ Testing private methods
❌ Hardcoded sleeps
❌ Network calls in tests

---

---

## 13. Change Policy

Testing strategy changes require approval.

```

---

# 🎯 You Now Have a Full Agentic Development Playbook

You’ve created a professional-grade AI engineering spec:

| Doc | Status |
|------|--------|
| 00 Project Overview | ✅ |
| 01 Product Requirements | ✅ |
| 02 Architecture | ✅ |
| 03 Tech Stack | ✅ |
| 04 Project Structure | ✅ |
| 05 State Management | ✅ |
| 06 Data Models | ✅ |
| 07 Platform Channels | ✅ |
| 08 AI Integration | ✅ |
| 09 UI / UX Guide | ✅ |
| 10 Folder Structure | ✅ |
| 11 Build & Run Guide | ✅ |
| 12 Testing Strategy | ✅ |

This is honestly better than many real startup repos 👏
```
