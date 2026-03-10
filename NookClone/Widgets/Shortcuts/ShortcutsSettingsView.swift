import SwiftUI

struct ShortcutsSettingsView: View {

    @ObservedObject private var manager = ShortcutsManager.shared

    var body: some View {
        Form {
            Section(header: Text("Pinned")) {
                if manager.pinned.isEmpty {
                    Text("None pinned yet — add from the list below.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else {
                    List {
                        ForEach(manager.pinned, id: \.self) { name in
                            HStack {
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 16)
                                Text(name)
                                Spacer()
                                Button {
                                    manager.unpin(name)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .onMove(perform: manager.movePinned)
                    }
                    .frame(minHeight: 60, maxHeight: 140)
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }

            Section(header: HStack {
                Text("Available Shortcuts")
                Spacer()
                Button("Refresh") { manager.fetchAvailable() }
                    .font(.caption)
                    .buttonStyle(.plain)
            }) {
                if manager.available.isEmpty {
                    Text("No shortcuts found. Open Shortcuts.app and create one.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else {
                    List(manager.available, id: \.self) { name in
                        HStack {
                            Text(name)
                            Spacer()
                            if manager.pinned.contains(name) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.secondary)
                            } else {
                                Button {
                                    manager.pin(name)
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(Color.accentColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(minHeight: 80, maxHeight: 200)
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }
        }
        .formStyle(.grouped)
    }
}
