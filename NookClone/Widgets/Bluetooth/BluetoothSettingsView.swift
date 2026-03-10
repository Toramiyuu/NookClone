import SwiftUI

struct BluetoothSettingsView: View {

    @ObservedObject private var manager = BluetoothManager.shared

    var body: some View {
        Form {
            Section("Paired Devices") {
                if manager.devices.isEmpty {
                    Text("No paired Bluetooth devices found.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(manager.devices) { device in
                        HStack(spacing: 10) {
                            Image(systemName: device.sfSymbol)
                                .frame(width: 16)
                                .foregroundStyle(device.isConnected ? .primary : .secondary)
                            Text(device.name)
                            Spacer()
                            Text(device.isConnected ? "Connected" : "Disconnected")
                                .font(.caption)
                                .foregroundStyle(device.isConnected ? .green : .secondary)
                        }
                    }
                }
            }
            Section("Actions") {
                Button("Refresh Devices") { manager.refresh() }
            }
        }
        .formStyle(.grouped)
    }
}
