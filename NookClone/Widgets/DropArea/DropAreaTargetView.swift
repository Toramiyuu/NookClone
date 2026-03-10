import SwiftUI
import AppKit

/// Action buttons shown after selecting a shelf item.
struct DropAreaTargetView: View {

    let item: DroppedItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.displayName)
                .font(.headline)
                .lineLimit(1)

            Divider()

            if let url = item.url {
                actionButton(title: "AirDrop", icon: "airplayvideo") { airdrop(url: url) }
                actionButton(title: "Open", icon: "arrow.up.forward.app") {
                    NSWorkspace.shared.open(url); dismiss()
                }
                actionButton(title: "Copy Path", icon: "doc.on.clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.path, forType: .string)
                    dismiss()
                }
                actionButton(title: "Share...", icon: "square.and.arrow.up") { share(url: url) }
            } else if let text = item.text {
                actionButton(title: "Copy Text", icon: "doc.on.clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    dismiss()
                }
                actionButton(title: "AirDrop", icon: "airplayvideo") { airdropText(text) }
            }

            Divider()

            actionButton(title: "Remove", icon: "trash", role: .destructive) {
                DropAreaStore.shared.remove(item.id)
                dismiss()
            }
        }
        .frame(minWidth: 180)
    }

    private func actionButton(
        title: String,
        icon: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private func airdrop(url: URL) {
        NSSharingService(named: .sendViaAirDrop)?.perform(withItems: [url])
        dismiss()
    }

    private func airdropText(_ text: String) {
        NSSharingService(named: .sendViaAirDrop)?.perform(withItems: [text])
        dismiss()
    }

    private func share(url: URL) {
        let picker = NSSharingServicePicker(items: [url])
        if let contentView = NSApp.keyWindow?.contentView {
            picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        }
        dismiss()
    }
}

// MARK: - Settings

class DropAreaSettings: ObservableObject {
    static let shared = DropAreaSettings()

    @Published var maxItems: Int {
        didSet { UserDefaults.standard.set(maxItems, forKey: "droparea.maxItems") }
    }

    private init() {
        let v = UserDefaults.standard.integer(forKey: "droparea.maxItems")
        maxItems = v > 0 ? v : 10
    }
}

struct DropAreaSettingsView: View {
    @ObservedObject private var settings = DropAreaSettings.shared
    @ObservedObject private var store = DropAreaStore.shared

    var body: some View {
        Form {
            Section("Shelf") {
                Stepper("Max items: \(settings.maxItems)", value: $settings.maxItems, in: 1...30)
            }
            Section("Actions") {
                Button("Clear Shelf", role: .destructive) {
                    store.clear()
                }
            }
        }
        .formStyle(.grouped)
    }
}
