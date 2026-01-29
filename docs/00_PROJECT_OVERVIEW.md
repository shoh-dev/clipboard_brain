# Clipboard Brain — Project Overview

## 1. Product Name

**Clipboard Brain** (working name)

A privacy-first, offline, AI-powered universal clipboard manager for macOS.

The product captures clipboard history locally, enriches it with on-device AI, and allows fast semantic search and reuse — without sending any data to the cloud.

---

## 2. Product Vision

Modern users copy hundreds of pieces of information every day:

- Code snippets
- URLs
- Passwords
- Notes
- Screenshots
- Commands
- Messages

Most of this data is lost after a few copies or becomes impossible to retrieve later.

Clipboard Brain aims to:

- Remember everything you copy.
- Organize it automatically using on-device AI.
- Make retrieval instant and intuitive.
- Preserve privacy by never sending user data to external servers.

The product must feel:

- Fast
- Reliable
- Private
- Native to macOS
- Invisible when not needed

---

## 3. Target Users

Primary users:

- Software developers
- Designers
- Product managers
- Researchers
- Power users
- Knowledge workers

User characteristics:

- Uses macOS daily.
- Values productivity and keyboard-driven workflows.
- Comfortable paying for high-quality utilities.
- Cares about privacy and performance.
- Wants tools that stay out of the way.

This is **not** a consumer social app, content app, or mobile-first product.

---

## 4. Core Value Proposition

Clipboard Brain provides:

1. **Persistent clipboard history**
   - Everything copied is stored locally.
   - Users never lose important copied data.

2. **AI-powered understanding**
   - Clipboard items are automatically tagged and summarized using on-device AI.
   - Semantic search allows searching by meaning, not only keywords.

3. **Privacy by design**
   - No cloud storage.
   - No external network calls for user data.
   - All processing happens on-device.

4. **Fast retrieval**
   - Global shortcut access.
   - Instant filtering and search.
   - Low latency interactions.

5. **Native desktop experience**
   - Menu bar integration.
   - Background operation.
   - Low resource usage.

---

## 5. What This Product Is NOT

The product explicitly avoids:

- ❌ Cloud synchronization between devices.
- ❌ User accounts or authentication.
- ❌ Social features or sharing platforms.
- ❌ Collaboration features.
- ❌ Analytics tracking of user content.
- ❌ Mobile application (at least for MVP).
- ❌ Replacing note-taking apps or task managers.
- ❌ Acting as a full automation platform (automation may come later).

If a feature does not directly improve clipboard productivity, it should be considered out of scope.

---

## 6. Non-Functional Goals

The system must prioritize:

- **Performance**
  - UI actions should feel instantaneous.
  - Background processing must not noticeably impact CPU or battery.

- **Stability**
  - App must run continuously for days without memory leaks or crashes.

- **Privacy**
  - No telemetry containing user content.
  - Local encryption where applicable.

- **Maintainability**
  - Clean architecture.
  - Clear separation of concerns.
  - Testable logic.

- **Extensibility**
  - Ability to add new AI features later without rewriting core systems.

---

## 7. Supported Platforms

MVP target:

- macOS (Apple Silicon preferred)

Future consideration (not MVP):

- Windows
- Linux

Mobile platforms are explicitly out of scope for this project.

---

## 8. Business Direction (High Level)

This product is intended to become a sustainable desktop utility business.

Potential monetization models:

- One-time purchase license.
- Freemium with paid pro features.

Exact pricing and monetization logic are defined in separate documents.

Revenue optimization is secondary to building a high-quality product.

---

## 9. Guiding Engineering Principles

All engineering decisions must follow:

1. **Clarity over cleverness**
2. **Explicit over implicit**
3. **Local-first architecture**
4. **Predictable behavior**
5. **Minimal dependencies**
6. **Readable code over micro-optimizations**
7. **Fail safely and transparently**

Avoid experimental or unstable technologies unless explicitly approved.

---

## 10. Definition of Success

The project is successful when:

- Users can reliably retrieve any previously copied item.
- Search feels fast and accurate.
- AI features run fully offline.
- The app feels native and polished.
- No sensitive data leaves the machine.
- Codebase remains understandable and maintainable.

---

## 11. Document Ownership

This document defines the product direction and must be treated as authoritative.

Any changes must be deliberate and reviewed before implementation.
