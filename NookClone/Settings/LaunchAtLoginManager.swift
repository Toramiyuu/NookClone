import ServiceManagement
import Foundation

/// Manages the launch-at-login state via ServiceManagement.
enum LaunchAtLoginManager {

    static func setEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Ignore failures — may occur if already registered/unregistered
            }
        } else {
            // Fallback for macOS < 13: use SMLoginItemSetEnabled with helper bundle
            // Not implemented for this deployment target (macOS 14+)
        }
    }

    static func isEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }
}
