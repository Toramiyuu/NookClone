import SwiftUI

struct ShortcutsView: View {

    @ObservedObject private var manager = ShortcutsManager.shared

    var body: some View {
        if manager.pinned.isEmpty {
            emptyState
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(manager.pinned, id: \.self) { name in
                        ShortcutTile(name: name)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 5) {
            Image(systemName: "arrow.trianglehead.2.clockwise")
                .foregroundStyle(.white.opacity(0.25))
            Text("No shortcuts pinned.\nOpen Settings to add shortcuts.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

private struct ShortcutTile: View {
    let name: String
    @State private var isHovered = false
    private let manager = ShortcutsManager.shared

    private var isRunning: Bool { manager.runningName == name }

    var body: some View {
        Button { manager.run(name) } label: {
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.opacity(isHovered ? 0.15 : 0.08))
                        .frame(width: 44, height: 44)

                    if isRunning {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                Text(name)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 56)
            }
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .disabled(manager.runningName != nil)
    }
}
