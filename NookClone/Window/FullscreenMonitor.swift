import AppKit

/// Monitors for fullscreen applications and calls back when state changes.
class FullscreenMonitor {

    private let onChange: (Bool) -> Void
    private var wsObservers: [Any] = []
    private var pollTimer: Timer?

    init(onChange: @escaping (Bool) -> Void) {
        self.onChange = onChange
        setupObservers()
    }

    deinit {
        pollTimer?.invalidate()
        wsObservers.forEach { NSWorkspace.shared.notificationCenter.removeObserver($0) }
    }

    private func setupObservers() {
        let wsCenter = NSWorkspace.shared.notificationCenter

        // App activation change
        wsObservers.append(wsCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.checkFullscreen() })

        // Space change (catches fullscreen apps on different spaces)
        wsObservers.append(wsCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.checkFullscreen() })

        // Periodic poll as safety net
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkFullscreen()
        }
    }

    private func checkFullscreen() {
        let isFullscreen = isFrontmostAppFullscreen()
        onChange(isFullscreen)
    }

    private func isFrontmostAppFullscreen() -> Bool {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return false }
        let pid = frontApp.processIdentifier
        guard pid > 0 else { return false }

        let axApp = AXUIElementCreateApplication(pid)
        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement] else { return false }

        return windows.contains { window in
            var fsRef: CFTypeRef?
            guard AXUIElementCopyAttributeValue(window, "AXFullScreen" as CFString, &fsRef) == .success else {
                return false
            }
            return (fsRef as? Bool) == true
        }
    }
}
