import Foundation
import CoreLocation

/// Manages location services for the app
@MainActor
class LocationManager: NSObject, ObservableObject {
    /// Shared instance for app-wide location tracking
    static let shared = LocationManager()

    private var manager: CLLocationManager?
    private let geocoder = CLGeocoder()

    /// Callback for one-time location requests
    private var locationCallback: ((CLLocation?) -> Void)?

    /// Minimum acceptable horizontal accuracy in meters
    private let minimumAccuracy: CLLocationAccuracy = 100

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = ""
    @Published var locationError: String?
    @Published var isRequestingLocation: Bool = false

    override init() {
        super.init()
        setupManager()
    }

    private func setupManager() {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager?.authorizationStatus ?? .notDetermined
    }

    deinit {
        manager?.delegate = nil
        manager = nil
    }

    func requestPermission() {
        manager?.requestWhenInUseAuthorization()
    }

    /// Check if location services are authorized
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    /// Check if location services are denied
    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    /// Request a single location update (battery efficient)
    func requestLocation() {
        locationError = nil
        isRequestingLocation = true
        manager?.requestLocation()
    }

    /// Request location with a callback when location is received
    func requestLocationWithCallback(completion: @escaping (CLLocation?) -> Void) {
        locationError = nil
        isRequestingLocation = true

        // If we already have a recent valid location (within 30 seconds), use it
        if let existingLocation = location,
           existingLocation.horizontalAccuracy <= minimumAccuracy,
           Date().timeIntervalSince(existingLocation.timestamp) < 30 {
            isRequestingLocation = false
            completion(existingLocation)
            return
        }

        // Store callback and request new location
        locationCallback = completion
        manager?.requestLocation()

        // Timeout after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.isRequestingLocation else { return }
            self.isRequestingLocation = false
            self.locationError = "Location request timed out"
            let callback = self.locationCallback
            self.locationCallback = nil
            callback?(self.location) // Return whatever we have
        }
    }

    /// Start continuous updates (use sparingly)
    func startUpdating() {
        locationError = nil
        manager?.startUpdatingLocation()
    }

    /// Stop continuous updates
    func stopUpdating() {
        manager?.stopUpdatingLocation()
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
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.authorizationStatus = manager.authorizationStatus

            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isRequestingLocation = false

            // Validate accuracy
            guard newLocation.horizontalAccuracy <= self.minimumAccuracy else {
                // If we have a callback waiting and accuracy is poor, still report it
                if let callback = self.locationCallback {
                    self.locationCallback = nil
                    callback(newLocation)
                }
                return
            }

            // Only update stored location if changed significantly (100m) or if callback is waiting
            let shouldUpdate = self.locationCallback != nil || self.location == nil ||
                (self.location != nil && newLocation.distance(from: self.location!) >= 100)

            if shouldUpdate {
                self.location = newLocation
                self.reverseGeocode(newLocation)
            }

            // Call any pending callback
            if let callback = self.locationCallback {
                self.locationCallback = nil
                callback(newLocation)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isRequestingLocation = false

            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.locationError = "Location access denied"
                case .locationUnknown:
                    self.locationError = "Unable to determine location"
                default:
                    self.locationError = "Location error: \(clError.localizedDescription)"
                }
            } else {
                self.locationError = error.localizedDescription
            }

            // Call any pending callback with nil
            if let callback = self.locationCallback {
                self.locationCallback = nil
                callback(nil)
            }
        }
    }
}
