import SwiftUI

class MediaWidgetSettings: ObservableObject {
    static let shared = MediaWidgetSettings()

    @Published var showArtwork: Bool {
        didSet { UserDefaults.standard.set(showArtwork, forKey: "media.showArtwork") }
    }
    @Published var showSpectrograph: Bool {
        didSet { UserDefaults.standard.set(showSpectrograph, forKey: "media.showSpectrograph") }
    }
    @Published var playerPreference: PlayerPreference {
        didSet { UserDefaults.standard.set(playerPreference.rawValue, forKey: "media.playerPreference") }
    }

    enum PlayerPreference: String, CaseIterable, Identifiable {
        case auto = "Auto"
        case music = "Apple Music"
        case spotify = "Spotify"
        var id: String { rawValue }
    }

    private init() {
        let d = UserDefaults.standard
        showArtwork = d.object(forKey: "media.showArtwork") as? Bool ?? true
        showSpectrograph = d.object(forKey: "media.showSpectrograph") as? Bool ?? true
        playerPreference = PlayerPreference(rawValue: d.string(forKey: "media.playerPreference") ?? "") ?? .auto
    }
}

struct MediaWidgetSettingsView: View {
    @ObservedObject private var settings = MediaWidgetSettings.shared

    var body: some View {
        Form {
            Section("Display") {
                Toggle("Show album artwork", isOn: $settings.showArtwork)
                Toggle("Show audio spectrograph", isOn: $settings.showSpectrograph)
            }
            Section("Player") {
                Picker("Preferred player", selection: $settings.playerPreference) {
                    ForEach(MediaWidgetSettings.PlayerPreference.allCases) { pref in
                        Text(pref.rawValue).tag(pref)
                    }
                }
                .pickerStyle(.radioGroup)
            }
        }
        .formStyle(.grouped)
    }
}
