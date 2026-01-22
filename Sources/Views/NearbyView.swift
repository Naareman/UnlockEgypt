import SwiftUI
import CoreLocation

struct NearbyView: View {
    let sites: [Site]
    @StateObject private var locationManager = LocationManager()
    @State private var sortedSites: [SiteWithDistance] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.accentColor)
                Text("Sites Near You")
                    .font(.headline)
            }

            // Location status
            locationStatusView

            // Sites list
            if !sortedSites.isEmpty {
                VStack(spacing: 12) {
                    ForEach(sortedSites) { item in
                        NavigationLink(destination: SiteDetailView(site: item.site)) {
                            NearbySiteRow(site: item.site, distance: item.formattedDistance)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                      locationManager.authorizationStatus == .authorizedAlways {
                // Loading or no sites
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Finding sites near you...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
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
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Location active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

        @unknown default:
            EmptyView()
        }
    }

    // MARK: - Helper Methods
    private func updateSortedSites(from userLocation: CLLocation) {
        sortedSites = sites.map { site in
            let distance = userLocation.distance(from: site.location)
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
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}

// MARK: - Nearby Site Row
struct NearbySiteRow: View {
    let site: Site
    let distance: String

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "building.columns")
                        .foregroundColor(.orange)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(site.era.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.caption2)
                    Text(distance)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.accentColor)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

// MARK: - Location Prompt Card
struct LocationPromptCard: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle")
                .font(.largeTitle)
                .foregroundColor(.accentColor)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text(buttonTitle)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
        location = locations.last
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            NearbyView(sites: SampleData.sites)
                .padding()
        }
    }
}
