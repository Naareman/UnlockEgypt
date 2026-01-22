import Foundation
import CoreLocation

/// Manages location services for the app
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = ""

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // Only update if location changed significantly (100m)
        if let oldLocation = location {
            if newLocation.distance(from: oldLocation) < 100 {
                return
            }
        }

        location = newLocation
        reverseGeocode(newLocation)
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first else { return }

            DispatchQueue.main.async {
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
