# Clipboard Brain — Build & Run Guide

## 1. Purpose of This Document

This document defines:

- How to set up the development environment.
- How to build and run the application.
- How to run macOS native components.
- How to debug Flutter and Swift code.
- How to validate builds.

The AI agent must follow these instructions exactly.

---

---

## 2. System Requirements

### Operating System

- macOS 13+ (Ventura or newer)

### Hardware

- Apple Silicon or Intel Mac

---

---

## 3. Required Tools

Install the following:

### Flutter

```bash
flutter --version
```

````

Must be stable channel.

---

### Xcode

- Latest stable Xcode from App Store.
- Command Line Tools installed:

```bash
xcode-select --install
```

---

### CocoaPods

```bash
sudo gem install cocoapods
```

---

---

## 4. Project Setup

From project root:

```bash
flutter pub get
flutter config --enable-macos-desktop
flutter create .
```

Enable macOS platform if missing:

```bash
flutter create --platforms=macos .
```

---

---

## 5. Running the App

### Run in Debug Mode

```bash
flutter run -d macos
```

---

---

## 6. Opening Native Project

```bash
open macos/Runner.xcworkspace
```

Use Xcode for:

- Swift plugin development
- Entitlements configuration
- Debugging native crashes

---

---

## 7. macOS Permissions Setup

Enable capabilities in Xcode:

- App Sandbox
- Clipboard access
- Background execution
- Accessibility (if needed)

Update entitlements accordingly.

---

---

## 8. Debugging

### Flutter Debugging

- Hot reload supported.
- Use Flutter DevTools.

---

### Native Debugging

- Set breakpoints in Swift files.
- View logs in Xcode console.

---

---

## 9. Build Release

```bash
flutter build macos
```

Output located in:

```
build/macos/Build/Products/Release/
```

---

---

## 10. Code Signing (Later)

- Developer ID signing required for distribution.
- Not required for local testing.

---

---

## 11. Clean Build

```bash
flutter clean
flutter pub get
```

---

---

## 12. Troubleshooting

| Issue                | Fix                     |
| -------------------- | ----------------------- |
| Pod errors           | cd macos && pod install |
| Missing macOS device | flutter doctor          |
| Xcode build fail     | Clean Build Folder      |
| Permission denied    | Check entitlements      |

---

---

## 13. Validation Checklist

- App launches successfully.
- Clipboard events received.
- No console errors.
- UI responsive.
- Native plugin loads correctly.

---

---

## 14. Forbidden

❌ Running random shell scripts
❌ Modifying Pods manually
❌ Editing generated Flutter files
❌ Disabling sandbox

---

---

## 15. Change Policy

Build process changes require approval.
````
