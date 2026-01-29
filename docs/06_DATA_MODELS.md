# Clipboard Brain — Data Models Specification

## 1. Purpose of This Document

This document defines:

- All core entities.
- Their fields and types.
- Immutability rules.
- Serialization contracts.
- Equality behavior.

No new fields or models may be added without updating this document.

---

---

## 2. Core Entity: ClipboardItem

Represents a single clipboard capture.

### Fields

| Field     | Type              | Required | Description                  |
| --------- | ----------------- | -------- | ---------------------------- |
| id        | String            | ✅       | Unique UUID                  |
| type      | ClipboardItemType | ✅       | Content type                 |
| plainText | String?           | Optional | Normalized text              |
| imagePath | String?           | Optional | Local cached image file path |
| filePaths | List<String>?     | Optional | Copied file paths            |
| createdAt | DateTime          | ✅       | Timestamp                    |
| isPinned  | bool              | ✅       | User pinned                  |
| tags      | List<String>      | ✅       | AI generated tags            |
| summary   | String?           | Optional | AI summary                   |
| language  | String?           | Optional | Detected language            |
| category  | String?           | Optional | AI category                  |

### Rules

- Only one content field may be non-null.
- Immutable after creation except:
  - isPinned
  - tags
  - summary
  - language
  - category

---

---

## 3. ClipboardItemType Enum

```dart
enum ClipboardItemType {
  text,
  image,
  files,
}
```

---

---

## 4. SearchQuery

Represents user search input.

### Fields

| Field      | Type   |
| ---------- | ------ |
| raw        | String |
| normalized | String |

---

---

## 5. SearchResult

Represents a ranked match.

### Fields

| Field | Type          |
| ----- | ------------- |
| item  | ClipboardItem |
| score | double        |

---

---

## 6. SettingsModel

Represents persisted user settings.

### Fields

| Field           | Type   | Default       |
| --------------- | ------ | ------------- |
| maxHistoryItems | int    | 2000          |
| enableAI        | bool   | true          |
| launchAtStartup | bool   | false         |
| enableMenuBar   | bool   | true          |
| globalShortcut  | String | "Cmd+Shift+V" |

---

---

## 7. Serialization Rules

- All entities must support:
  - toJson()
  - fromJson()

- DateTime stored as ISO-8601 string.
- Enums stored as string.

---

---

## 8. Equality Rules

- Entities must override == and hashCode.
- Equality based on id only for ClipboardItem.

---

---

## 9. Validation Rules

- id must be UUID v4.
- plainText max length must be configurable.
- filePaths must exist when stored.
- imagePath must exist when stored.

---

---

## 10. Backward Compatibility

- Fields may only be added with defaults.
- Never remove fields without migration.

---

---

## 11. Forbidden

❌ Dynamic maps as models
❌ Runtime-generated schemas
❌ Mutable public fields
❌ Multiple content fields populated

---

---

## 12. Change Policy

Data model changes require approval.
