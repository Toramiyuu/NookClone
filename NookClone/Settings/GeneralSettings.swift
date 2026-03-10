import SwiftUI
import Combine

/// Persisted general app settings backed by UserDefaults.
class GeneralSettings: ObservableObject {

    static let shared = GeneralSettings()

    @Published var openOnHover: Bool {
        didSet { UserDefaults.standard.set(openOnHover, forKey: "general.openOnHover") }
    }
    @Published var openOnClick: Bool {
        didSet { UserDefaults.standard.set(openOnClick, forKey: "general.openOnClick") }
    }
    @Published var notchWidthOffset: CGFloat {
        didSet { UserDefaults.standard.set(Double(notchWidthOffset), forKey: "general.notchWidthOffset") }
    }
    @Published var notchHeightOffset: CGFloat {
        didSet { UserDefaults.standard.set(Double(notchHeightOffset), forKey: "general.notchHeightOffset") }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "general.launchAtLogin")
            LaunchAtLoginManager.setEnabled(launchAtLogin)
        }
    }
    @Published var hotkeyEnabled: Bool {
        didSet { UserDefaults.standard.set(hotkeyEnabled, forKey: "general.hotkeyEnabled") }
    }

    private init() {
        let defaults = UserDefaults.standard
        openOnHover = defaults.object(forKey: "general.openOnHover") as? Bool ?? true
        openOnClick = defaults.object(forKey: "general.openOnClick") as? Bool ?? true
        notchWidthOffset = CGFloat(defaults.double(forKey: "general.notchWidthOffset"))
        notchHeightOffset = CGFloat(defaults.double(forKey: "general.notchHeightOffset"))
        launchAtLogin = defaults.object(forKey: "general.launchAtLogin") as? Bool ?? false
        hotkeyEnabled = defaults.object(forKey: "general.hotkeyEnabled") as? Bool ?? true
    }
}
