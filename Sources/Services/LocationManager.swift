import Foundation
import CoreLocation

/// Manages location services for the app
@MainActor
class LocationManager: NSObject, ObservableObject {
    /// Shared instance for app-wide location tracking
    static let shared = LocationManager()

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = ""
    @Published var locationError: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Request a single location update (battery efficient)
    func requestLocation() {
        locationError = nil
        manager.requestLocation()
    }

    /// Start continuous updates (use sparingly)
    func startUpdating() {
        locationError = nil
        manager.startUpdatingLocation()
    }

    /// Stop continuous updates
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            Task { @MainActor [weak self] in
                guard let self = self, let placemark = placemarks?.first else { return }

                var parts: [String] = []

                if let neighborhood = placemark.subLocality {
                    parts.append(neighborhood)
                }
                if let city = placemark.locality {
                    parts.append(city)
                }
                if let country = placemark.country {
                    parts.append(country)
                }

                self.locationName = parts.joined(separator: ", ")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus

            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        Task { @MainActor in
            // Only update if location changed significantly (100m)
            if let oldLocation = location {
                if newLocation.distance(from: oldLocation) < 100 {
                    return
                }
            }

            location = newLocation
            reverseGeocode(newLocation)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationError = "Location access denied"
                case .locationUnknown:
                    locationError = "Unable to determine location"
                default:
                    locationError = "Location error: \(clError.localizedDescription)"
                }
            } else {
                locationError = error.localizedDescription
            }
        }
    }
}
