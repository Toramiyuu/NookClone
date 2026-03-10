import SwiftUI
import AppKit

/// NSTextView-based rich text editor wrapped for SwiftUI.
struct NoteEditorView: NSViewRepresentable {

    @Binding var text: NSAttributedString

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }

        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isRichText = true
        textView.allowsUndo = true
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: CGFloat(NotesWidgetSettings.shared.fontSize))
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.textContainerInset = NSSize(width: 4, height: 4)

        if text.length > 0 {
            textView.textStorage?.setAttributedString(text)
        }

        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        // Only update if external change (not from user typing)
        if context.coordinator.isEditing { return }
        if textView.attributedString() != text {
            textView.textStorage?.setAttributedString(text)
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NoteEditorView
        weak var textView: NSTextView?
        var isEditing = false

        init(parent: NoteEditorView) {
            self.parent = parent
        }

        func textDidBeginEditing(_ notification: Notification) { isEditing = true }
        func textDidEndEditing(_ notification: Notification) { isEditing = false }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            let content = tv.attributedString()
            parent.text = content
            NotesManager.shared.save(content)
        }
    }
}

/// Toolbar with bold/italic/underline buttons.
/// Uses NSApp.sendAction to target the first responder (the focused NSTextView).
struct TextFormattingToolbar: View {

    var body: some View {
        HStack(spacing: 4) {
            formatButton(title: "B", selector: Selector("toggleBoldface:"))
            formatButton(title: "I", selector: Selector("toggleItalics:"))
            formatButton(title: "U", selector: Selector("toggleUnderline:"))
        }
    }

    private func formatButton(title: String, selector: Selector) -> some View {
        Button {
            NSApp.sendAction(selector, to: nil, from: nil)
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 22, height: 22)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}
