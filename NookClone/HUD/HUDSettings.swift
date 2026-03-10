import SwiftUI

class HUDSettings: ObservableObject {
    static let shared = HUDSettings()

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "hud.enabled") }
    }
    @Published var dismissTimeout: Double {
        didSet { UserDefaults.standard.set(dismissTimeout, forKey: "hud.dismissTimeout") }
    }
    @Published var position: HUDPosition {
        didSet { UserDefaults.standard.set(position.rawValue, forKey: "hud.position") }
    }

    enum HUDPosition: String, CaseIterable, Identifiable {
        case belowNotch = "Below Notch"
        case bottomLeft = "Bottom Left"
        case bottomRight = "Bottom Right"
        var id: String { rawValue }
    }

    private init() {
        let d = UserDefaults.standard
        isEnabled = d.object(forKey: "hud.enabled") as? Bool ?? true
        dismissTimeout = d.object(forKey: "hud.dismissTimeout") as? Double ?? 2.0
        position = HUDPosition(rawValue: d.string(forKey: "hud.position") ?? "") ?? .belowNotch
    }
}

struct HUDSettingsView: View {
    @ObservedObject private var settings = HUDSettings.shared

    var body: some View {
        Form {
            Section("HUD Replacement") {
                Toggle("Replace system HUD", isOn: $settings.isEnabled)
                    .onChange(of: settings.isEnabled) { _, enabled in
                        if enabled { HUDInterceptor.shared.start() }
                        else { HUDInterceptor.shared.stop() }
                    }
                HStack {
                    Text("Auto-dismiss after")
                    Slider(value: $settings.dismissTimeout, in: 1...5, step: 0.5)
                    Text("\(settings.dismissTimeout, specifier: "%.1f")s")
                        .monospacedDigit()
                        .frame(width: 36)
                }
            }
            Section("Position") {
                Picker("Position", selection: $settings.position) {
                    ForEach(HUDSettings.HUDPosition.allCases) { pos in
                        Text(pos.rawValue).tag(pos)
                    }
                }
                .pickerStyle(.radioGroup)
            }
        }
        .formStyle(.grouped)
    }
}

struct HUDWidgetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("HUD Replacement")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Text("Press volume or brightness keys to see the overlay.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
