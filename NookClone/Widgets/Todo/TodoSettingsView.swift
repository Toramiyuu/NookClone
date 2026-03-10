import SwiftUI

struct TodoSettingsView: View {

    @ObservedObject private var manager = TodoManager.shared

    var body: some View {
        Form {
            Section("Summary") {
                HStack {
                    Text("Total tasks")
                    Spacer()
                    Text("\(manager.items.count)").foregroundStyle(.secondary)
                }
                HStack {
                    Text("Completed")
                    Spacer()
                    Text("\(manager.items.filter { $0.isDone }.count)").foregroundStyle(.secondary)
                }
            }
            Section("Actions") {
                Button("Clear Completed", role: .destructive) { manager.clearDone() }
                    .disabled(manager.items.filter { $0.isDone }.isEmpty)
                Button("Clear All", role: .destructive) { manager.items.removeAll() }
                    .disabled(manager.items.isEmpty)
            }
        }
        .formStyle(.grouped)
    }
}
