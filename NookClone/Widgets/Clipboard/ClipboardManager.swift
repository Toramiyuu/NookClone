import AppKit
import Combine

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let text: String
    let date: Date

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.date = Date()
    }
}

class ClipboardManager: ObservableObject {

    static let shared = ClipboardManager()

    @Published var items: [ClipboardItem] = []

    private var pollTimer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private var isExpanded = false
    private let savePath: URL

    var maxItems: Int {
        get { UserDefaults.standard.integer(forKey: "clipboard.maxItems").nonZeroOr(20) }
        set { UserDefaults.standard.set(newValue, forKey: "clipboard.maxItems") }
    }

    var autoClearOnQuit: Bool {
        get { UserDefaults.standard.bool(forKey: "clipboard.autoClearOnQuit") }
        set { UserDefaults.standard.set(newValue, forKey: "clipboard.autoClearOnQuit") }
    }

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("NookClone", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        savePath = dir.appendingPathComponent("clipboard.json")
        loadFromDisk()
        startPolling(interval: 2.0)
        observePanel()
        observeTermination()
    }

    deinit { pollTimer?.invalidate() }

    // MARK: - App termination

    private func observeTermination() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self, self.autoClearOnQuit else { return }
            self.items = []
            try? FileManager.default.removeItem(at: self.savePath)
        }
    }

    // MARK: - Panel observation

    private func observePanel() {
        NotificationCenter.default.addObserver(forName: .notchPanelExpandedChanged, object: nil, queue: .main) { [weak self] note in
            guard let self else { return }
            let expanded = (note.object as? Bool) ?? false
            self.isExpanded = expanded
            self.restartTimer()
        }
    }

    private func restartTimer() {
        pollTimer?.invalidate()
        startPolling(interval: isExpanded ? 0.5 : 2.0)
    }

    // MARK: - Polling

    private func startPolling(interval: TimeInterval) {
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        pollTimer?.tolerance = interval * 0.2
    }

    private func checkClipboard() {
        let count = NSPasteboard.general.changeCount
        guard count != lastChangeCount else { return }
        lastChangeCount = count

        if let text = NSPasteboard.general.string(forType: .string), !text.isEmpty {
            DispatchQueue.main.async { self.addItem(text: text) }
        }
    }

    // MARK: - Management

    func addItem(text: String) {
        // Don't duplicate consecutive identical items
        if items.first?.text == text { return }
        let item = ClipboardItem(text: text)
        items.insert(item, at: 0)
        if items.count > maxItems { items = Array(items.prefix(maxItems)) }
        saveToDisk()
    }

    func copyItem(_ item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.text, forType: .string)
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func remove(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveToDisk()
    }

    func clear() {
        items.removeAll()
        try? FileManager.default.removeItem(at: savePath)
    }

    // MARK: - Persistence

    private func saveToDisk() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: savePath, options: .atomic)
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: savePath),
              let saved = try? JSONDecoder().decode([ClipboardItem].self, from: data) else { return }
        items = saved
    }
}

private extension Int {
    func nonZeroOr(_ fallback: Int) -> Int { self > 0 ? self : fallback }
}
