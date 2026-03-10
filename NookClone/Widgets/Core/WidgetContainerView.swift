import SwiftUI

/// Renders enabled widgets as horizontal tabs inside the notch panel.
struct WidgetContainerView: View {

    @ObservedObject private var registry = WidgetRegistry.shared
    // Empty string = "no explicit selection, use first enabled widget"
    // @AppStorage does not support Optional<String> so we use "" as the sentinel
    @AppStorage("nookclone.lastWidgetTab") private var selectedWidgetID: String = ""
    @Namespace private var tabNamespace

    var body: some View {
        let enabled = registry.enabledWidgets

        if enabled.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                if enabled.count > 1 {
                    tabBar(enabled)
                }
                widgetContent(enabled)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func tabBar(_ widgets: [WidgetRegistry.WidgetEntry]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(widgets) { widget in
                    let selected = isSelected(widget, in: widgets)
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            selectedWidgetID = widget.id
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: widget.icon)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(selected ? .white : .white.opacity(0.35))
                            Text(widget.title)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(selected ? .white.opacity(0.9) : .white.opacity(0.3))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background {
                            if selected {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.white.opacity(0.18))
                                    .matchedGeometryEffect(id: "tabIndicator", in: tabNamespace)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .scaleEffect(selected ? 1.05 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: selected)
                }
            }
            .padding(.horizontal, 2)
        }
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private func widgetContent(_ widgets: [WidgetRegistry.WidgetEntry]) -> some View {
        // Resolve the active ID: stored value if it exists in enabled widgets, else first
        let activeID = (!selectedWidgetID.isEmpty && widgets.contains(where: { $0.id == selectedWidgetID }))
            ? selectedWidgetID
            : widgets.first?.id
        if let id = activeID, let widget = widgets.first(where: { $0.id == id }) {
            widget.makeBody()
                .onAppear {
                    NotificationCenter.default.post(
                        name: .notchPanelHeightChanged,
                        object: widget.preferredHeight
                    )
                }
        }
    }

    private func isSelected(_ widget: WidgetRegistry.WidgetEntry, in widgets: [WidgetRegistry.WidgetEntry]) -> Bool {
        if selectedWidgetID.isEmpty || !widgets.contains(where: { $0.id == selectedWidgetID }) {
            return widgets.first?.id == widget.id
        }
        return selectedWidgetID == widget.id
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.dashed")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.3))
            Text("No widgets enabled")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}
