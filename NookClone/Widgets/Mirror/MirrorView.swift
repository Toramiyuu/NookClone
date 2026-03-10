import SwiftUI
import AVFoundation
import AppKit

struct MirrorView: View {

    @ObservedObject private var manager = MirrorManager.shared

    var body: some View {
        Group {
            switch manager.authStatus {
            case .authorized:
                CameraPreviewRepresentable(manager: manager)
                    .frame(maxWidth: .infinity)
                    .frame(height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .onAppear { manager.startIfAuthorized() }
                    .onDisappear { manager.stop() }
            case .notDetermined:
                Button("Allow Camera Access") { manager.startIfAuthorized() }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            default:
                Label("Camera access denied. Enable in\nSystem Settings → Privacy → Camera.", systemImage: "camera.slash")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - NSViewRepresentable wrapper

private struct CameraPreviewRepresentable: NSViewRepresentable {
    let manager: MirrorManager

    func makeNSView(context: Context) -> CameraPreviewNSView {
        CameraPreviewNSView(session: manager.session, mirrored: manager.isMirrored)
    }

    func updateNSView(_ view: CameraPreviewNSView, context: Context) {
        view.setMirrored(manager.isMirrored)
    }
}

// MARK: - NSView hosting AVCaptureVideoPreviewLayer

class CameraPreviewNSView: NSView {
    private let previewLayer: AVCaptureVideoPreviewLayer

    init(session: AVCaptureSession, mirrored: Bool) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame: .zero)
        wantsLayer = true
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
        previewLayer.connection?.isVideoMirrored = mirrored
        layer?.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layout() {
        super.layout()
        previewLayer.frame = bounds
    }

    func setMirrored(_ mirrored: Bool) {
        previewLayer.connection?.isVideoMirrored = mirrored
    }
}
