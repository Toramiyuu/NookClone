import SwiftUI

class WeatherSettings: ObservableObject {

    static let shared = WeatherSettings()

    @Published var useFahrenheit: Bool {
        didSet { UserDefaults.standard.set(useFahrenheit, forKey: "weather.useFahrenheit") }
    }

    @Published var manualCity: String {
        didSet { UserDefaults.standard.set(manualCity, forKey: "weather.manualCity") }
    }

    private init() {
        useFahrenheit = UserDefaults.standard.bool(forKey: "weather.useFahrenheit")
        manualCity    = UserDefaults.standard.string(forKey: "weather.manualCity") ?? ""
    }
}

struct WeatherSettingsView: View {

    @ObservedObject private var settings = WeatherSettings.shared
    @ObservedObject private var manager  = WeatherManager.shared

    var body: some View {
        Form {
            Section("Display") {
                Toggle("Use Fahrenheit", isOn: $settings.useFahrenheit)
            }
            Section("Location") {
                TextField("City override (e.g. Tokyo)", text: $settings.manualCity)
                    .onSubmit { manager.fetchByCity(settings.manualCity) }

                HStack {
                    Text("Current location")
                    Spacer()
                    Text(manager.cityName.isEmpty ? "Detecting…" : manager.cityName)
                        .foregroundStyle(.secondary)
                }
                Button(settings.manualCity.isEmpty ? "Refresh from Device Location" : "Apply City Override") {
                    if settings.manualCity.trimmingCharacters(in: .whitespaces).isEmpty {
                        manager.requestLocationAndFetch()
                    } else {
                        manager.fetchByCity(settings.manualCity)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
