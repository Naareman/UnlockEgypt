import SwiftUI
import CoreLocation

struct NearbyView: View {
    let sites: [Site]
    @StateObject private var locationManager = LocationManager()
    @State private var sortedSites: [SiteWithDistance] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color(hex: "d4af37"))
                        Text("SITES NEAR YOU")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "d4af37"))
                            .tracking(2)
                    }

                    Text("Discover historical sites around your location")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal)

                // Location status
                locationStatusView
                    .padding(.horizontal)

                // Sites list
                if !sortedSites.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        // Current location info
                        if let location = locationManager.location {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.green)
                                    if !locationManager.locationName.isEmpty {
                                        Text(locationManager.locationName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white.opacity(0.8))
                                    } else {
                                        Text("Getting location...")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                Text("\(location.coordinate.latitude, specifier: "%.4f"), \(location.coordinate.longitude, specifier: "%.4f")")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal)
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(sortedSites) { item in
                                NavigationLink(destination: SiteDetailView(site: item.site)) {
                                    NearbySiteRow(site: item.site, distance: item.formattedDistance)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                          locationManager.authorizationStatus == .authorizedAlways {
                    // Loading or no sites
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Color(hex: "d4af37"))
                        Text("Finding sites near you...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                updateSortedSites(from: location)
            }
        }
    }

    // MARK: - Location Status View
    @ViewBuilder
    private var locationStatusView: some View {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            LocationPromptCard(
                title: "Enable Location",
                message: "Allow location access to discover historical sites near you.",
                buttonTitle: "Enable",
                action: { locationManager.requestPermission() }
            )

        case .denied, .restricted:
            LocationPromptCard(
                title: "Location Disabled",
                message: "Enable location in Settings to see nearby sites.",
                buttonTitle: "Open Settings",
                action: { openSettings() }
            )

        case .authorizedWhenInUse, .authorizedAlways:
            if locationManager.location != nil {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Location active")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

        @unknown default:
            EmptyView()
        }
    }

    // MARK: - Helper Methods
    private func updateSortedSites(from userLocation: CLLocation) {
        sortedSites = sites.map { site in
            let siteLocation = CLLocation(
                latitude: site.coordinates.latitude,
                longitude: site.coordinates.longitude
            )
            let distance = userLocation.distance(from: siteLocation)
            return SiteWithDistance(site: site, distance: distance)
        }
        .sorted { $0.distance < $1.distance }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Site With Distance
struct SiteWithDistance: Identifiable {
    var id: String { site.id }
    let site: Site
    let distance: CLLocationDistance

    var formattedDistance: String {
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else if distance < 100_000 {
            return String(format: "%.1f km", distance / 1000)
        } else {
            return String(format: "%.0f km", distance / 1000)
        }
    }
}

// MARK: - Nearby Site Row (Dark Theme)
struct NearbySiteRow: View {
    let site: Site
    let distance: String

    var body: some View {
        HStack(spacing: 14) {
            // Image placeholder with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color(hex: "d4af37").opacity(0.3), Color(hex: "8b7355").opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)

                Image(systemName: site.placeType.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: "d4af37"))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(site.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(site.city.rawValue)
                    .font(.caption)
                    .foregroundColor(Color(hex: "d4af37"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text(distance)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(hex: "d4af37"))

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "d4af37").opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Location Prompt Card (Dark Theme)
struct LocationPromptCard: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "d4af37").opacity(0.2))
                    .frame(width: 70, height: 70)
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "d4af37"))
            }

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text(buttonTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(hex: "d4af37"))
                    .cornerRadius(25)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "d4af37").opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Location Manager
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

#Preview {
    NavigationStack {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            NearbyView(sites: PreviewData.sites)
        }
    }
    .preferredColorScheme(.dark)
}
