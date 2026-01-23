import SwiftUI
import CoreLocation

struct NearbyView: View {
    let sites: [Site]
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var sortedSites: [SiteWithDistance] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Theme.Colors.gold)
                        Text("SITES NEAR YOU")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.gold)
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
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Theme.Colors.gold)
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        if distance < 1000 {
            return "\(Int(distance)) m"
        } else if distance < 100_000 {
            return String(format: "%.1f km", distance / 1000)
        } else {
            let km = Int(distance / 1000)
            let formatted = formatter.string(from: NSNumber(value: km)) ?? "\(km)"
            return "\(formatted) km"
        }
    }
}

// MARK: - Nearby Site Row
struct NearbySiteRow: View {
    let site: Site
    let distance: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.goldGradient)
                    .frame(width: 60, height: 60)

                Image(systemName: site.placeType.icon)
                    .font(.title2)
                    .foregroundColor(Theme.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(site.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(site.city.rawValue)
                    .font(.caption)
                    .foregroundColor(Theme.Colors.gold)
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
                .foregroundColor(Theme.Colors.gold)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding()
        .background(Theme.Colors.cardBackgroundSubtle)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Location Prompt Card
struct LocationPromptCard: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.2))
                    .frame(width: 70, height: 70)
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.gold)
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
                    .background(Theme.Colors.gold)
                    .cornerRadius(25)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.cardBackgroundSubtle)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.Colors.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ZStack {
            GradientBackground()
            NearbyView(sites: PreviewData.sites)
        }
    }
    .preferredColorScheme(.dark)
}
