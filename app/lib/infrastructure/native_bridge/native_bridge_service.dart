import 'package:flutter/services.dart';

/// Service responsible for all communication between Flutter and Native macOS code.
///
/// See Memory 07: Platform Channels Specification.
class NativeBridgeService {
  static const String kNativeMethodChannel = 'clipboard_brain/methods';
  static const String kNativeEventChannel = 'clipboard_brain/events';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  NativeBridgeService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ?? const MethodChannel(kNativeMethodChannel),
       _eventChannel = eventChannel ?? const EventChannel(kNativeEventChannel);

  /// Stream of clipboard change events coming from native side.
  ///
  /// Payload schema:
  /// {
  ///   "type": "text | image | files",
  ///   "text": "string | null",
  ///   "imagePath": "string | null",
  ///   "filePaths": ["string"] | null,
  ///   "timestamp": "ISO-8601 string"
  /// }
  Stream<dynamic> get clipboardEvents => _eventChannel.receiveBroadcastStream();

  /// Returns current clipboard content snapshot.
  Future<Map<String, dynamic>> getClipboardSnapshot() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'getClipboardSnapshot',
      );
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Starts background clipboard monitoring.
  Future<bool> startClipboardListener() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'startClipboardListener',
      );
      return result?['started'] == true;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Stops clipboard monitoring.
  Future<bool> stopClipboardListener() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'stopClipboardListener',
      );
      return result?['stopped'] == true;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Validates clipboard access permissions.
  Future<bool> requestPermissions() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'requestPermissions',
      );
      return result?['granted'] == true;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  Exception _handlePlatformException(PlatformException e) {
    // TODO: Map to domain exceptions
    return e;
  }
}
