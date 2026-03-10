import AppKit

/// Manages mouse-enter/exit tracking on the notch panel view.
/// Click handling is done via SwiftUI's onTapGesture in NookPanelView.
class NotchHoverController: NSObject {

    private weak var trackedView: NSView?
    private var trackingArea: NSTrackingArea?

    private let onHover: (Bool) -> Void

    init(view: NSView, onHover: @escaping (Bool) -> Void) {
        self.onHover = onHover
        super.init()
        self.trackedView = view
        installTrackingArea(on: view)
    }

    private func installTrackingArea(on view: NSView) {
        if let area = trackingArea { view.removeTrackingArea(area) }
        let area = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(area)
        trackingArea = area
    }

    func updateTrackingArea() {
        guard let view = trackedView else { return }
        installTrackingArea(on: view)
    }

    func mouseEntered(with event: NSEvent) { onHover(true) }
    func mouseExited(with event: NSEvent)  { onHover(false) }
}
