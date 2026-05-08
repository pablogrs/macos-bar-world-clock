// AppDelegate.swift
import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem?
    var timer: Timer?
    var settingsWindow: NSWindow?
    
    // Custom main to ensure the delegate is set up correctly without a storyboard
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
    
    // Computed property to get the current list of zones to display
    var displayTimeZones: [(name: String, identifier: String, flag: String)] {
        var zones: [(name: String, identifier: String, flag: String)] = []
        if TimeZonesStore.shared.showLocal {
            zones.append(("Local", TimeZone.current.identifier, "📍"))
        }
        for tz in TimeZonesStore.shared.selectedTimeZones {
            zones.append((tz.name, tz.identifier, tz.flag))
        }
        return zones
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("Application did finish launching")
        
        // Observe changes in settings
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged), name: Notification.Name("TimeZonesChanged"), object: nil)
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set up the status item button
        if let button = statusItem?.button {
            button.action = #selector(statusItemClicked(_:))
            button.target = self
        }
        
        // Start the timer to update time every second
        updateTimeDisplay()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
        
        // Create and set up the menu
        setupMenu()
    }
    
    @objc func updateTimeDisplay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let zones = displayTimeZones
        let timeStrings = zones.map { tz -> String in
            formatter.timeZone = TimeZone(identifier: tz.identifier)
            return "\(tz.flag) \(formatter.string(from: Date()))"
        }
        
        // Compact display for the menu bar
        statusItem?.button?.title = timeStrings.isEmpty ? "World Clock" : timeStrings.joined(separator: "  ")
    }
    
    @objc func settingsChanged() {
        updateTimeDisplay()
        setupMenu()
    }
    
    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        // The menu will automatically show when clicked since it's assigned to statusItem?.menu
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let zones = displayTimeZones
        
        if zones.isEmpty {
            let item = NSMenuItem(title: "No zones selected", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            for (index, tz) in zones.enumerated() {
                formatter.timeZone = TimeZone(identifier: tz.identifier)
                let title = "\(tz.flag) \(tz.name): \(formatter.string(from: Date()))"
                let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                menuItem.isEnabled = false
                menuItem.tag = index
                menu.addItem(menuItem)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Add settings item
        let settingsItem = NSMenuItem(title: "Configuration...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Add quit item
        let quitItem = NSMenuItem(title: "Quit macOS World Clock", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        
        // Update the menu items every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, self.statusItem?.menu == menu else {
                timer.invalidate()
                return
            }
            let currentZones = self.displayTimeZones
            for item in menu.items {
                if item.tag < currentZones.count && !item.isSeparatorItem && item.action == nil {
                    let tz = currentZones[item.tag]
                    formatter.timeZone = TimeZone(identifier: tz.identifier)
                    item.title = "\(tz.flag) \(tz.name): \(formatter.string(from: Date()))"
                }
            }
        }
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let contentView = SettingsView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("Settings")
            window.contentView = NSHostingView(rootView: contentView)
            window.title = "World Clock Configuration"
            window.isReleasedWhenClosed = false // Keep the window instance
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
