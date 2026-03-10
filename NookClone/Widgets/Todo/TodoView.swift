import SwiftUI

struct TodoView: View {

    @ObservedObject private var manager = TodoManager.shared
    @State private var newText = ""

    var body: some View {
        VStack(spacing: 6) {
            if manager.items.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 2) {
                        ForEach(manager.items) { item in
                            TodoRow(item: item)
                        }
                    }
                }
                .frame(maxHeight: 88)
            }

            // Add field
            HStack(spacing: 6) {
                TextField("New task…", text: $newText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
                    .onSubmit { submit() }

                Button(action: submit) {
                    Image(systemName: "return")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(newText.isEmpty ? 0.2 : 0.5))
                }
                .buttonStyle(.plain)
                .disabled(newText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 6))
        }
    }

    private func submit() {
        manager.add(newText)
        newText = ""
    }

    private var emptyState: some View {
        VStack(spacing: 5) {
            Image(systemName: "checkmark.circle")
                .foregroundStyle(.white.opacity(0.2))
            Text("No tasks")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

private struct TodoRow: View {
    let item: TodoItem
    private let manager = TodoManager.shared

    var body: some View {
        HStack(spacing: 8) {
            Button { withAnimation { manager.toggle(item) } } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundStyle(item.isDone ? .green : .white.opacity(0.35))
            }
            .buttonStyle(.plain)

            Text(item.text)
                .font(.system(size: 11))
                .foregroundStyle(item.isDone ? .white.opacity(0.3) : .white.opacity(0.85))
                .strikethrough(item.isDone, color: .white.opacity(0.3))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button { withAnimation { manager.delete(item) } } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.25))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 5))
    }
}
