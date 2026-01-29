# Clipboard Brain — State Management Specification

## 1. Purpose of This Document

This document defines:

- How application state is modeled.
- How state flows through the app.
- How ViewModels are written.
- How UI consumes state.
- How async state is handled.
- What is strictly forbidden.

All ViewModels must follow this document exactly.

---

---

## 2. State Management Stack

### Approved

- provider
- ChangeNotifier
- ValueNotifier (only for local widget state)

### Forbidden

- Any other state management library
- Streams for UI state
- Global mutable state
- Static state

---

---

## 3. ViewModel Responsibilities

Each ViewModel:

- Owns all state for one screen.
- Coordinates domain services.
- Converts domain models into UI-ready state.
- Handles loading, error, and empty states.
- Exposes only immutable getters.

ViewModels must NOT:

- Perform UI rendering.
- Access platform channels directly.
- Contain widget references.
- Hold BuildContext.

---

---

## 4. ViewModel Structure Template

Every ViewModel must follow this pattern:

```dart
class ExampleViewModel extends ChangeNotifier {
  // Private state
  bool _isLoading = false;
  String? _errorMessage;
  List<Item> _items = [];

  // Public getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Item> get items => List.unmodifiable(_items);

  // Commands
  Future<void> load() async {
    _setLoading(true);
    try {
      _items = await _service.fetchItems();
    } catch (e) {
      _errorMessage = 'Failed to load items';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
```

---

---

## 5. State Update Rules

- State mutations must only occur inside ViewModel methods.
- Every mutation must call notifyListeners().
- No public setters allowed.
- Collections must be exposed as unmodifiable views.
- State changes must be minimal and predictable.

---

---

## 6. Async State Handling

All async operations must:

- Set loading state before execution.
- Catch and convert errors into user-safe messages.
- Never throw uncaught exceptions to UI.
- Cancel safely if ViewModel is disposed.

---

---

## 7. UI Consumption Rules

UI must:

- Use Consumer or context.watch().
- Never mutate state directly.
- Never call services directly.
- React only to ViewModel getters.

Example:

```dart
Consumer<MainWindowViewModel>(
  builder: (_, vm, __) {
    if (vm.isLoading) return LoadingView();
    if (vm.errorMessage != null) return ErrorView(vm.errorMessage!);
    return ListView(...);
  },
);
```

---

---

## 8. Derived State Rules

Derived state must:

- Be computed inside ViewModel getters.
- Never computed in Widgets.
- Never cached unless expensive.

---

---

## 9. Global App State

Global state must be limited to:

- App lifecycle state
- Theme state
- Settings state

All global state lives in app-level ViewModels.

---

---

## 10. Disposal Rules

ViewModels must:

- Cancel timers, streams, listeners.
- Dispose native subscriptions.
- Release resources.

Override dispose() properly.

---

---

## 11. Error State Model

Each ViewModel must expose:

- errorMessage (nullable)
- Optional error type enum (if needed)

Never expose raw exceptions.

---

---

## 12. Performance Rules

- Avoid excessive notifyListeners calls.
- Batch state updates where possible.
- Avoid heavy computation in getters.

---

---

## 13. Forbidden Patterns

❌ Mutable public fields
❌ Exposing internal lists directly
❌ notifyListeners inside loops
❌ Holding BuildContext
❌ Business logic in Widgets
❌ Streams for UI

---

---

## 14. Change Policy

State management changes require approval.
