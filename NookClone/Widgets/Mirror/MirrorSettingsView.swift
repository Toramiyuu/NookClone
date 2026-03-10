import SwiftUI

struct MirrorSettingsView: View {

    @ObservedObject private var manager = MirrorManager.shared

    var body: some View {
        Form {
            Section("Camera") {
                Toggle("Mirror video horizontally", isOn: $manager.isMirrored)
            }
            Section("Info") {
                Text("The camera starts when you switch to the Mirror tab and stops when you switch away, saving battery.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
