import Foundation
import CoreLocation
import Combine

// Open-Meteo WMO weather code → description + SF Symbol
private func weatherInfo(code: Int, isDay: Bool) -> (description: String, symbol: String) {
    switch code {
    case 0:  return ("Clear",        isDay ? "sun.max.fill" : "moon.stars.fill")
    case 1:  return ("Mostly clear", isDay ? "sun.min.fill" : "moon.fill")
    case 2:  return ("Partly cloudy","cloud.sun.fill")
    case 3:  return ("Overcast",     "cloud.fill")
    case 45, 48: return ("Foggy",    "cloud.fog.fill")
    case 51, 53, 55: return ("Drizzle", "cloud.drizzle.fill")
    case 61, 63, 65: return ("Rain",    "cloud.rain.fill")
    case 71, 73, 75: return ("Snow",    "cloud.snow.fill")
    case 80, 81, 82: return ("Showers", "cloud.heavyrain.fill")
    case 95, 96, 97, 98, 99: return ("Thunderstorm", "cloud.bolt.rain.fill")
    default: return ("Unknown",      "questionmark.circle")
    }
}

class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = WeatherManager()

    @Published var temperatureC: Double?
    @Published var dailyHighC: Double?
    @Published var dailyLowC: Double?
    @Published var windspeedKph: Double?
    @Published var weatherDescription: String = "Loading…"
    @Published var weatherSymbol: String = "cloud.fill"
    @Published var cityName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var refreshTimer: Timer?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        scheduleRefresh()
    }

    // MARK: - Public

    func requestLocationAndFetch() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorized, .authorizedAlways:
            locationManager.requestLocation()
        default:
            DispatchQueue.main.async { self.errorMessage = "Location access denied." }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorized || status == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        reverseGeocode(location)
        fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { self.errorMessage = "Location unavailable." }
    }

    // MARK: - Manual city override

    func fetchByCity(_ city: String) {
        let trimmed = city.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { requestLocationAndFetch(); return }
        CLGeocoder().geocodeAddressString(trimmed) { [weak self] placemarks, _ in
            guard let self, let location = placemarks?.first?.location else {
                DispatchQueue.main.async { self?.errorMessage = "City not found." }
                return
            }
            DispatchQueue.main.async { self.cityName = placemarks?.first?.locality ?? trimmed }
            self.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }

    // MARK: - Reverse geocode

    private func reverseGeocode(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async { self?.cityName = city }
            }
        }
    }

    // MARK: - Weather fetch (Open-Meteo, no API key)

    private func fetchWeather(lat: Double, lon: Double) {
        let urlStr = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=\(lat)&longitude=\(lon)"
            + "&current_weather=true"
            + "&daily=temperature_2m_max,temperature_2m_min"
            + "&timezone=auto"
        guard let url = URL(string: urlStr) else { return }

        DispatchQueue.main.async { self.isLoading = true }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let cw = json["current_weather"] as? [String: Any] else {
                    self.errorMessage = "Bad response"
                    return
                }
                let temp  = cw["temperature"]  as? Double ?? 0
                let wind  = cw["windspeed"]    as? Double ?? 0
                let code  = cw["weathercode"]  as? Int    ?? 0
                let isDay = (cw["is_day"]      as? Int ?? 1) == 1
                let info  = weatherInfo(code: code, isDay: isDay)

                self.temperatureC       = temp
                self.windspeedKph       = wind
                self.weatherDescription = info.description
                self.weatherSymbol      = info.symbol
                self.errorMessage       = nil

                // Parse daily high/low (first element of today's forecast)
                if let daily = json["daily"] as? [String: Any] {
                    self.dailyHighC = (daily["temperature_2m_max"] as? [Double])?.first
                    self.dailyLowC  = (daily["temperature_2m_min"] as? [Double])?.first
                }
            }
        }.resume()
    }

    // MARK: - Periodic refresh (every 15 minutes)

    private func scheduleRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in
            self?.fetchCurrent()
        }
        fetchCurrent()
    }

    /// Fetches weather using manual city if configured, otherwise falls back to GPS.
    private func fetchCurrent() {
        let city = WeatherSettings.shared.manualCity.trimmingCharacters(in: .whitespaces)
        if city.isEmpty {
            requestLocationAndFetch()
        } else {
            fetchByCity(city)
        }
    }
}
