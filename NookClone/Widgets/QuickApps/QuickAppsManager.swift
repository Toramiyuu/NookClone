import AppKit
import Combine

/// Manages the list of pinned apps for the Quick Apps launcher widget.
class QuickAppsManager: ObservableObject {

    static let shared = QuickAppsManager()

    @Published var bundleIDs: [String] {
        didSet { UserDefaults.standard.set(bundleIDs, forKey: "quickapps.bundleIDs") }
    }

    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: "quickapps.bundleIDs")
        bundleIDs = saved ?? [
            "com.apple.finder",
            "com.apple.Safari",
            "com.apple.Terminal",
            "com.apple.systempreferences"
        ]
    }

    func resolveURL(for bundleID: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
    }

    func icon(for bundleID: String) -> NSImage {
        if let url = resolveURL(for: bundleID) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return NSWorkspace.shared.icon(forFile: "/System/Library/CoreServices/Finder.app")
    }

    func displayName(for bundleID: String) -> String {
        if let url = resolveURL(for: bundleID) {
            return Bundle(url: url)?.infoDictionary?["CFBundleName"] as? String
                ?? url.deletingPathExtension().lastPathComponent
        }
        // Show last two components so "com.apple.finder" → "apple.finder"
        let parts = bundleID.components(separatedBy: ".")
        return parts.suffix(2).joined(separator: ".")
    }

    func launch(_ bundleID: String) {
        guard let url = resolveURL(for: bundleID) else { return }
        NSWorkspace.shared.openApplication(at: url, configuration: .init(), completionHandler: nil)
    }

    func add(bundleID: String) {
        guard !bundleIDs.contains(bundleID) else { return }
        bundleIDs.append(bundleID)
    }

    func remove(at offsets: IndexSet) {
        bundleIDs.remove(atOffsets: offsets)
    }

    func move(from source: IndexSet, to destination: Int) {
        bundleIDs.move(fromOffsets: source, toOffset: destination)
    }
}
