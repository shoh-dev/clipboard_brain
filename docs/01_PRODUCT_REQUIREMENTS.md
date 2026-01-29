# Clipboard Brain — Product Requirements

## 1. Purpose of This Document

This document defines:
- Functional requirements for the MVP.
- Explicit feature scope.
- Out-of-scope items.
- Behavioral expectations.
- Acceptance criteria.

Any feature not explicitly listed here must NOT be implemented unless approved.

---

## 2. Product Scope (MVP)

The MVP is a macOS desktop application that:

1. Listens to system clipboard changes.
2. Stores clipboard history locally.
3. Displays clipboard history in a searchable UI.
4. Enriches clipboard items using on-device AI.
5. Allows fast reuse of clipboard content.
6. Runs quietly in the background.

---

---

## 3. Supported Clipboard Content Types

The system must support:

### ✅ Text
- Plain text
- Rich text converted to plain text
- Code snippets
- URLs

### ✅ Images
- Screenshots
- Copied images
- Image files copied from Finder

### ✅ File References
- File paths when files are copied
- Basic metadata (filename, size, extension)

### ❌ Not Supported (MVP)
- Video data
- Audio data
- Large binary blobs
- Drag-and-drop clipboard streams
- Custom app-specific formats

Unsupported content should be ignored safely.

---

---

## 4. Clipboard Capture Behavior

The application must:

- Detect clipboard changes automatically.
- Avoid duplicating identical consecutive clipboard entries.
- Normalize clipboard content into a consistent internal format.
- Timestamp each clipboard item.
- Capture clipboard data without blocking UI thread.
- Continue running in background.

The application must NOT:
- Modify clipboard content automatically.
- Interfere with normal copy/paste behavior.

---

---

## 5. Storage Requirements

The system must:

- Persist clipboard history locally.
- Survive application restarts.
- Store data encrypted if feasible.
- Support configurable maximum history size (default limit required).
- Automatically prune old items when limits are exceeded.

The system must NOT:
- Store clipboard data in the cloud.
- Transmit clipboard data externally.

---

---

## 6. Search Requirements

The system must support:

### 🔍 Keyword Search
- Exact text matching.
- Partial matching.
- Case-insensitive.

### 🧠 Semantic Search (AI)
- Search by meaning, not just literal words.
- Rank results by relevance.
- Work offline using on-device AI.

Search must:
- Return results under 200ms for typical datasets (<5,000 items).
- Update results dynamically as user types.

---

---

## 7. AI Enrichment Requirements

Each clipboard item should be enriched with:

- Auto-generated tags (keywords).
- Short summary for long text (optional).
- Language detection.
- Content category classification.

AI processing must:
- Run fully on-device.
- Be asynchronous and non-blocking.
- Fail gracefully if unavailable.
- Cache results to avoid repeated computation.

AI must NOT:
- Send any user data to external servers.
- Require network connectivity.

---

---

## 8. User Interface Requirements

The application must provide:

### 🖥 Main Window
- Search input field.
- List of clipboard items.
- Preview panel for selected item.
- Basic actions:
  - Copy back to clipboard
  - Pin / Unpin
  - Delete

### 📌 Menu Bar Mode
- Quick search popup.
- Recently copied items list.
- Ability to open main app.

### ⚙️ Settings Screen
- Enable / disable background launch.
- Enable / disable AI features.
- History size limit.
- Keyboard shortcut configuration.

---

---

## 9. Performance Requirements

The system must:

- Launch in under 2 seconds.
- Consume minimal CPU while idle.
- Avoid memory leaks.
- Handle at least 5,000 clipboard items smoothly.

---

---

## 10. Privacy & Security Requirements

The application must:

- Store all user data locally.
- Avoid logging sensitive content.
- Encrypt sensitive storage where possible.
- Clearly communicate privacy guarantees to users.

---

---

## 11. Error Handling Requirements

The system must:

- Never crash due to clipboard content.
- Recover gracefully from native failures.
- Log internal errors safely.
- Provide user-friendly error messages where appropriate.

---

---

## 12. Out of Scope (Explicit)

The MVP must NOT include:

- Cloud sync.
- Multi-device support.
- User authentication.
- Collaboration features.
- Sharing links.
- Automation workflows.
- Plugin system.
- Mobile version.
- Web version.
- External integrations.

---

---

## 13. Acceptance Criteria

The MVP is considered complete when:

- Clipboard history reliably captures data.
- Search works accurately and fast.
- AI enrichment runs locally.
- App runs quietly in background.
- No external network calls are made for data.
- UI is stable and responsive.
- All documented requirements are implemented.

---

## 14. Change Management

Any change to this document must be reviewed and agreed before implementation.
