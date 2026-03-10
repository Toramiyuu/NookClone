import Foundation
import IOBluetooth
import CoreBluetooth

struct BluetoothDevice: Identifiable {
    let id: String          // address string
    let name: String
    let isConnected: Bool
    let batteryPercent: Int?   // nil if unknown
    let sfSymbol: String
    let raw: IOBluetoothDevice
}

class BluetoothManager: ObservableObject {

    static let shared = BluetoothManager()

    @Published var devices: [BluetoothDevice] = []

    private var refreshTimer: Timer?
    private var connectNotif: IOBluetoothUserNotification?
    private var disconnectNotif: IOBluetoothUserNotification?

    private init() {
        refresh()
        startTimer()
        observeConnectionEvents()
    }

    // MARK: - Refresh

    func refresh() {
        // On macOS 15, IOBluetoothDevice.pairedDevices() crashes if Bluetooth access
        // hasn't been explicitly authorized yet. Guard here — the widget shows empty
        // until the user grants permission in System Settings > Privacy > Bluetooth.
        guard CBManager.authorization == .allowedAlways else { return }
        let paired = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
        devices = paired.map { device in
            let battery = device.value(forKey: "batteryPercent") as? Int
            return BluetoothDevice(
                id: device.addressString ?? UUID().uuidString,
                name: device.nameOrAddress ?? "Unknown",
                isConnected: device.isConnected(),
                batteryPercent: battery,
                sfSymbol: sfSymbol(for: device),
                raw: device
            )
        }
        .sorted { $0.isConnected && !$1.isConnected }
    }

    func connect(_ device: BluetoothDevice) {
        device.raw.openConnection(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.refresh() }
    }

    func disconnect(_ device: BluetoothDevice) {
        device.raw.closeConnection()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.refresh() }
    }

    // MARK: - Private

    private func startTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    private func observeConnectionEvents() {
        connectNotif = IOBluetoothDevice.register(
            forConnectNotifications: self,
            selector: #selector(deviceConnected(_:device:))
        )
    }

    @objc private func deviceConnected(_ notif: IOBluetoothUserNotification, device: IOBluetoothDevice) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.refresh() }
    }

    // MARK: - Icon mapping

    private func sfSymbol(for device: IOBluetoothDevice) -> String {
        let major = Int(device.deviceClassMajor)
        let minor = Int(device.deviceClassMinor)

        switch major {
        case 0x0100: return "desktopcomputer"               // Computer
        case 0x0200: return "phone"                         // Phone
        case 0x0400:                                        // Audio/Video
            switch minor {
            case 0x04, 0x08, 0x18: return "headphones"     // Headphones / headset / hi-fi
            default:               return "speaker.wave.2"
            }
        case 0x0500:                                        // Peripheral (HID)
            let minorBits = minor & 0xFF
            if minorBits & 0x40 != 0 && minorBits & 0x80 != 0 { return "keyboard" }  // combo
            if minorBits & 0x40 != 0 { return "keyboard" }
            if minorBits & 0x80 != 0 { return "computermouse" }
            return "gamecontroller"
        default: return "bluetooth"
        }
    }
}
