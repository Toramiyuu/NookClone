import SwiftUI

class SystemMonitorSettings: ObservableObject {

    static let shared = SystemMonitorSettings()

    static let pollIntervalOptions: [TimeInterval] = [1, 2, 5]

    @Published var showCPU: Bool {
        didSet { UserDefaults.standard.set(showCPU, forKey: "sysmon.showCPU") }
    }
    @Published var showMemory: Bool {
        didSet { UserDefaults.standard.set(showMemory, forKey: "sysmon.showMemory") }
    }
    @Published var showBattery: Bool {
        didSet { UserDefaults.standard.set(showBattery, forKey: "sysmon.showBattery") }
    }
    @Published var pollInterval: TimeInterval {
        didSet {
            UserDefaults.standard.set(pollInterval, forKey: "sysmon.pollInterval")
            SystemMonitorManager.shared.applyPollInterval(pollInterval)
        }
    }

    private init() {
        let d = UserDefaults.standard
        showCPU     = d.object(forKey: "sysmon.showCPU")     == nil ? true : d.bool(forKey: "sysmon.showCPU")
        showMemory  = d.object(forKey: "sysmon.showMemory")  == nil ? true : d.bool(forKey: "sysmon.showMemory")
        showBattery = d.object(forKey: "sysmon.showBattery") == nil ? true : d.bool(forKey: "sysmon.showBattery")
        let saved   = d.object(forKey: "sysmon.pollInterval") as? TimeInterval ?? 2.0
        pollInterval = Self.pollIntervalOptions.contains(saved) ? saved : 2.0
    }
}

struct SystemMonitorSettingsView: View {

    @ObservedObject private var settings = SystemMonitorSettings.shared
    @ObservedObject private var monitor  = SystemMonitorManager.shared

    var body: some View {
        Form {
            Section("Metrics") {
                Toggle("Show CPU", isOn: $settings.showCPU)
                Toggle("Show Memory", isOn: $settings.showMemory)
                if monitor.hasBattery {
                    Toggle("Show Battery", isOn: $settings.showBattery)
                }
            }
            Section("Polling") {
                Picker("Update interval", selection: $settings.pollInterval) {
                    Text("1 second").tag(TimeInterval(1))
                    Text("2 seconds").tag(TimeInterval(2))
                    Text("5 seconds").tag(TimeInterval(5))
                }
                .pickerStyle(.segmented)
            }
        }
        .formStyle(.grouped)
    }
}
