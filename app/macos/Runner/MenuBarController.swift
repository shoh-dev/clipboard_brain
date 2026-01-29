import Cocoa

/// Controls the menu bar status item for quick clipboard access.
class MenuBarController: NSObject, NSWindowDelegate {
    
    private var statusItem: NSStatusItem?
    private var mainWindow: NSWindow?
    
    static let shared = MenuBarController()
    
    private override init() {
        super.init()
    }
    
    func setup(with window: NSWindow) {
        self.mainWindow = window
        window.delegate = self
        window.isReleasedWhenClosed = false
        createStatusItem()
    }
    
    private func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let button = statusItem?.button else { return }
        
        // Use a system symbol for the clipboard
        if let image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Brain") {
            image.isTemplate = true
            button.image = image
        } else {
            // Fallback to text if system symbol not available
            button.title = "📋"
        }
        
        button.action = #selector(statusItemClicked)
        button.target = self
        
        // Create context menu for right-click
        let menu = NSMenu()
        
        let showItem = NSMenuItem(title: "Show Clipboard Brain", action: #selector(showMainWindow), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        // Set the menu (appears on right-click)
        statusItem?.menu = menu
    }
    
    @objc private func statusItemClicked() {
        toggleMainWindow()
    }
    
    @objc private func showMainWindow() {
        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func toggleMainWindow() {
        guard let window = mainWindow else { return }
        
        if window.isVisible {
            window.orderOut(nil)
        } else {
            showMainWindow()
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Instead of closing, just hide the window
        sender.orderOut(nil)
        return false
    }
}
