import AppKit
import SwiftUI

/// Borderless overlay window that displays volume/brightness HUD.
class HUDOverlayWindow: NSWindow {

    static let shared = HUDOverlayWindow()

    private var dismissTimer: Timer?
    private var hostingController: NSHostingController<HUDContainerView>?

    private init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 72),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        ignoresMouseEvents = true
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 10)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        isReleasedWhenClosed = false

        let controller = NSHostingController(rootView: HUDContainerView())
        contentViewController = controller
        hostingController = controller
        alphaValue = 0
    }

    func show(type: HUDType, value: Float) {
        hostingController?.rootView = HUDContainerView(type: type, value: value)
        reposition()

        if alphaValue < 0.1 {
            orderFront(nil)
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.15
                animator().alphaValue = 1
            }
        } else {
            alphaValue = 1
        }

        scheduleDismiss()
    }

    private func scheduleDismiss() {
        dismissTimer?.invalidate()
        let timeout = HUDSettings.shared.dismissTimeout
        dismissTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }

    private func dismiss() {
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            animator().alphaValue = 0
        } completionHandler: {
            self.orderOut(nil)
        }
    }

    private func reposition() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let windowSize = frame.size

        let origin: NSPoint
        switch HUDSettings.shared.position {
        case .belowNotch:
            let notchRect = NotchScreenDetector.notchRect(on: screen)
            origin = NSPoint(
                x: notchRect.midX - windowSize.width / 2,
                y: notchRect.minY - windowSize.height - 12
            )
        case .bottomLeft:
            origin = NSPoint(x: screenFrame.minX + 20, y: screenFrame.minY + 20)
        case .bottomRight:
            origin = NSPoint(x: screenFrame.maxX - windowSize.width - 20, y: screenFrame.minY + 20)
        }

        setFrameOrigin(origin)
    }
}

enum HUDType {
    case volume(muted: Bool)
    case brightness
}

struct HUDContainerView: View {
    var type: HUDType = .volume(muted: false)
    var value: Float = 0

    var body: some View {
        switch type {
        case .volume(let muted): VolumeIndicatorView(value: value, isMuted: muted)
        case .brightness: BrightnessIndicatorView(value: value)
        }
    }
}
