import SwiftUI

class NotesWidgetSettings: ObservableObject {
    static let shared = NotesWidgetSettings()

    @Published var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "notes.fontSize") }
    }
    @Published var codeHighlighting: Bool {
        didSet { UserDefaults.standard.set(codeHighlighting, forKey: "notes.codeHighlighting") }
    }

    private init() {
        let d = UserDefaults.standard
        fontSize = d.object(forKey: "notes.fontSize") as? Double ?? 13
        codeHighlighting = d.object(forKey: "notes.codeHighlighting") as? Bool ?? true
    }
}

struct NotesWidgetSettingsView: View {
    @ObservedObject private var settings = NotesWidgetSettings.shared

    var body: some View {
        Form {
            Section("Editor") {
                HStack {
                    Text("Font size")
                    Slider(value: $settings.fontSize, in: 10...24, step: 1)
                    Text("\(Int(settings.fontSize))pt")
                        .monospacedDigit()
                        .frame(width: 40)
                }
                Toggle("Code syntax highlighting", isOn: $settings.codeHighlighting)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Notes widget view

struct NotesView: View {
    @State private var text: NSAttributedString = NotesManager.shared.noteContent

    var body: some View {
        VStack(spacing: 6) {
            TextFormattingToolbar()
                .frame(maxWidth: .infinity, alignment: .leading)
            NoteEditorView(text: $text)
                .frame(minHeight: 80)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
