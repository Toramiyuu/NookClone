import SwiftUI

struct ClipboardSettingsView: View {

    @ObservedObject private var manager = ClipboardManager.shared
    @State private var maxItems: Int = ClipboardManager.shared.maxItems
    @State private var autoClear: Bool = ClipboardManager.shared.autoClearOnQuit

    var body: some View {
        Form {
            Section("History") {
                Stepper("Max items: \(maxItems)", value: $maxItems, in: 5...100, step: 5)
                    .onChange(of: maxItems) { _, v in manager.maxItems = v }
                Toggle("Clear history on quit", isOn: $autoClear)
                    .onChange(of: autoClear) { _, v in manager.autoClearOnQuit = v }
            }
            Section("Actions") {
                Button("Clear All History", role: .destructive) {
                    manager.clear()
                }
            }
        }
        .formStyle(.grouped)
    }
}
