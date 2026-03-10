import SwiftUI
import AppKit

struct QuickAppsView: View {

    @ObservedObject private var manager = QuickAppsManager.shared

    var body: some View {
        if manager.bundleIDs.isEmpty {
            emptyState
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(manager.bundleIDs, id: \.self) { id in
                        AppIconButton(bundleID: id)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
    }

    private var emptyState: some View {
        Text("No apps configured.\nOpen Settings to add apps.")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.4))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
    }
}

private struct AppIconButton: View {

    let bundleID: String
    @State private var isHovered = false
    private let manager = QuickAppsManager.shared

    var body: some View {
        let available = manager.resolveURL(for: bundleID) != nil

        Button {
            manager.launch(bundleID)
        } label: {
            VStack(spacing: 5) {
                Image(nsImage: manager.icon(for: bundleID))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .opacity(available ? 1 : 0.4)
                    .scaleEffect(isHovered ? 1.12 : 1.0)

                Text(manager.displayName(for: bundleID))
                    .font(.system(size: 9))
                    .foregroundStyle(available ? .white.opacity(0.7) : .white.opacity(0.3))
                    .lineLimit(1)
                    .frame(width: 48)
            }
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
        .help(available ? manager.displayName(for: bundleID) : "\(bundleID) (not installed)")
    }
}
