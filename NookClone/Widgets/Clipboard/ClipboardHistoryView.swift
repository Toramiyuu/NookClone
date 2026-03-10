import SwiftUI

struct ClipboardHistoryView: View {

    @ObservedObject private var manager = ClipboardManager.shared
    @State private var copiedID: UUID? = nil

    var body: some View {
        if manager.items.isEmpty {
            emptyState
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(manager.items) { item in
                        ClipboardItemRow(item: item, copiedID: $copiedID) {
                            manager.copyItem(item)
                            withAnimation { copiedID = item.id }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                if copiedID == item.id { copiedID = nil }
                            }
                        } onDelete: {
                            withAnimation { manager.remove(item) }
                        }
                    }
                }
            }
            .frame(maxHeight: 110)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "clipboard")
                .foregroundStyle(.white.opacity(0.3))
            Text("Nothing copied yet")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

private struct ClipboardItemRow: View {
    let item: ClipboardItem
    @Binding var copiedID: UUID?
    let onCopy: () -> Void
    let onDelete: () -> Void

    private var isCopied: Bool { copiedID == item.id }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onCopy) {
                HStack(spacing: 6) {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 10))
                        .foregroundStyle(isCopied ? .green : .white.opacity(0.4))
                        .frame(width: 14)

                    Text(item.text)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(item.date, style: .time)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.white.opacity(isCopied ? 0.1 : 0.05), in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
    }
}
