import SwiftUI

struct AboutView: View {

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.topthird.inset.filled")
                .font(.system(size: 64))
                .foregroundStyle(.primary)

            VStack(spacing: 4) {
                Text("NookClone")
                    .font(.title.bold())
                Text("Version \(version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("A clean-room SwiftUI replica of the NotchNook notch utility for macOS.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)

            Divider()
                .frame(maxWidth: 200)

            Text("Built with SwiftUI, EventKit, ScriptingBridge, AVFoundation, and IOKit.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(minWidth: 380)
    }
}
