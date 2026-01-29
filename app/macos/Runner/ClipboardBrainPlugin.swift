import Cocoa
import FlutterMacOS

/// Native macOS plugin for Clipboard Brain.
///
/// Handles clipboard monitoring via NSPasteboard polling and
/// communicates with Flutter via MethodChannel and EventChannel.
public class ClipboardBrainPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  
  private var eventSink: FlutterEventSink?
  private var clipboardTimer: Timer?
  private var lastChangeCount: Int = 0
  private let pasteboard = NSPasteboard.general
  
  // MARK: - Plugin Registration
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: "clipboard_brain/methods",
      binaryMessenger: registrar.messenger
    )
    let eventChannel = FlutterEventChannel(
      name: "clipboard_brain/events",
      binaryMessenger: registrar.messenger
    )
    
    let instance = ClipboardBrainPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }
  
  // MARK: - MethodChannel Handler
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getClipboardSnapshot":
      result(getClipboardContent())
      
    case "startClipboardListener":
      startMonitoring()
      result(["started": true])
      
    case "stopClipboardListener":
      stopMonitoring()
      result(["stopped": true])
      
    case "requestPermissions":
      // macOS clipboard access doesn't require explicit permission prompts
      result(["granted": true])
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - EventChannel StreamHandler
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    startMonitoring()
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopMonitoring()
    self.eventSink = nil
    return nil
  }
  
  // MARK: - Clipboard Monitoring
  
  private func startMonitoring() {
    guard clipboardTimer == nil else { return }
    
    lastChangeCount = pasteboard.changeCount
    
    // Poll every 500ms for clipboard changes
    clipboardTimer = Timer.scheduledTimer(
      withTimeInterval: 0.5,
      repeats: true
    ) { [weak self] _ in
      self?.checkForClipboardChanges()
    }
    
    // Ensure timer runs even when UI is tracking
    RunLoop.main.add(clipboardTimer!, forMode: .common)
  }
  
  private func stopMonitoring() {
    clipboardTimer?.invalidate()
    clipboardTimer = nil
  }
  
  private func checkForClipboardChanges() {
    let currentChangeCount = pasteboard.changeCount
    
    guard currentChangeCount != lastChangeCount else { return }
    lastChangeCount = currentChangeCount
    
    let content = getClipboardContent()
    eventSink?(content)
  }
  
  // MARK: - Clipboard Content Extraction
  
  private func getClipboardContent() -> [String: Any?] {
    let timestamp = ISO8601DateFormatter().string(from: Date())
    
    // Check for files first
    if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL], !fileURLs.isEmpty {
      let paths = fileURLs.map { $0.path }
      return [
        "type": "files",
        "text": nil,
        "imagePath": nil,
        "filePaths": paths,
        "timestamp": timestamp
      ]
    }
    
    // Check for images
    if let image = NSImage(pasteboard: pasteboard) {
      if let imagePath = saveImageToTemp(image) {
        return [
          "type": "image",
          "text": nil,
          "imagePath": imagePath,
          "filePaths": nil,
          "timestamp": timestamp
        ]
      }
    }
    
    // Check for text (including URLs as text)
    if let text = pasteboard.string(forType: .string) {
      return [
        "type": "text",
        "text": text,
        "imagePath": nil,
        "filePaths": nil,
        "timestamp": timestamp
      ]
    }
    
    // Unknown or empty clipboard
    return [
      "type": "text",
      "text": "",
      "imagePath": nil,
      "filePaths": nil,
      "timestamp": timestamp
    ]
  }
  
  // MARK: - Image Handling
  
  private func saveImageToTemp(_ image: NSImage) -> String? {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
      return nil
    }
    
    let fileName = UUID().uuidString + ".png"
    let tempDir = FileManager.default.temporaryDirectory
    let filePath = tempDir.appendingPathComponent("clipboard_brain").appendingPathComponent(fileName)
    
    do {
      try FileManager.default.createDirectory(
        at: filePath.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try pngData.write(to: filePath)
      return filePath.path
    } catch {
      print("ClipboardBrainPlugin: Failed to save image - \(error)")
      return nil
    }
  }
}
