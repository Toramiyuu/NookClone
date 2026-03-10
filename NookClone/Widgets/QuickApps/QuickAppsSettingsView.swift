import SwiftUI
import AppKit

struct QuickAppsSettingsView: View {

    @ObservedObject private var manager = QuickAppsManager.shared

    var body: some View {
        Form {
            Section("Apps") {
                List {
                    ForEach(manager.bundleIDs, id: \.self) { id in
                        HStack(spacing: 10) {
                            Image(nsImage: manager.icon(for: id))
                                .resizable()
                                .frame(width: 24, height: 24)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            Text(manager.displayName(for: id))
                            Spacer()
                            Text(id)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { manager.remove(at: $0) }
                    .onMove { manager.move(from: $0, to: $1) }
                }
                .frame(minHeight: 140)
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Button("Add App...") { pickApp() }
            }
        }
        .formStyle(.grouped)
    }

    private func pickApp() {
        let panel = NSOpenPanel()
        panel.title = "Choose Application"
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications")

        if panel.runModal() == .OK, let url = panel.url {
            let id = Bundle(url: url)?.bundleIdentifier ?? url.deletingPathExtension().lastPathComponent
            manager.add(bundleID: id)
        }
    }
}
