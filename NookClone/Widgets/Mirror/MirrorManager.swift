import AVFoundation
import Combine

class MirrorManager: ObservableObject {

    static let shared = MirrorManager()

    @Published var isMirrored: Bool {
        didSet { UserDefaults.standard.set(isMirrored, forKey: "mirror.isMirrored") }
    }
    @Published var authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    let session = AVCaptureSession()
    private var isConfigured = false

    private init() {
        isMirrored = UserDefaults.standard.object(forKey: "mirror.isMirrored") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "mirror.isMirrored")
    }

    func startIfAuthorized() {
        authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            if !isConfigured { configure() }
            guard !session.isRunning else { return }
            DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.authStatus = AVCaptureDevice.authorizationStatus(for: .video)
                    self?.startIfAuthorized()
                }
            }
        default: break
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { self.session.stopRunning() }
    }

    private func configure() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.beginConfiguration()
        session.sessionPreset = .high
        if session.canAddInput(input) { session.addInput(input) }
        session.commitConfiguration()
        isConfigured = true
    }
}
