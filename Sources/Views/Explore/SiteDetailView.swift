import SwiftUI

struct SiteDetailView: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var selectedTab: SiteTab = .explore

    private var isFavorite: Bool {
        viewModel.isFavorite(siteId: site.id)
    }

    private var hasDiscoveryKey: Bool {
        viewModel.hasExplorerBadge(for: site.id)
    }

    /// Check if user is within 500m of the site
    private var isNearSite: Bool {
        guard let userLocation = locationManager.location else { return false }
        let siteLocation = site.location
        let distance = userLocation.distance(from: siteLocation)
        return distance <= 500 // 500 meters
    }

    /// Show prompt when user is near and hasn't earned Discovery Key yet
    private var shouldShowProximityPrompt: Bool {
        isNearSite && !hasDiscoveryKey && selectedTab != .discover
    }

    var body: some View {
        ZStack {
            // Dark background
            Theme.Colors.darkBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection

                    // Content
                    VStack(spacing: 20) {
                        siteHeader

                        // Proximity prompt (when user is near site)
                        if shouldShowProximityPrompt {
                            ProximityPrompt {
                                withAnimation {
                                    selectedTab = .discover
                                }
                            }
                        }

                        tabSelector

                        Group {
                            switch selectedTab {
                            case .explore:
                                exploreContent
                            case .discover:
                                discoverContent
                            case .info:
                                infoContent
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.easeInOut(duration: 0.25), value: selectedTab)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleFavorite(siteId: site.id)
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .white)
                }
            }
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Multi-layer gradient background for depth
            ZStack {
                LinearGradient(
                    colors: [Theme.Colors.gold.opacity(0.5), Theme.Colors.sand.opacity(0.3), Theme.Colors.darkBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Decorative pattern overlay
                GeometryReader { geo in
                    Path { path in
                        let width = geo.size.width
                        let height = geo.size.height
                        // Create subtle hieroglyph-like pattern
                        for i in stride(from: 0, to: width, by: 60) {
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i + 30, y: height * 0.3))
                        }
                    }
                    .stroke(Theme.Colors.gold.opacity(0.1), lineWidth: 1)
                }
            }
            .frame(height: 280)

            // Large decorative icon
            VStack {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Theme.Colors.gold.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .blur(radius: 20)

                    Image(systemName: site.placeType.icon)
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(Theme.Colors.gold.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -20)

            // Info overlay with gradient backdrop
            VStack(alignment: .leading, spacing: 8) {
                Spacer()

                // Tags
                HStack(spacing: 8) {
                    TagBadge(text: site.era.rawValue, icon: "calendar")
                    TagBadge(text: site.placeType.rawValue, icon: site.placeType.icon)
                    TagBadge(text: site.city.rawValue, icon: "mappin")
                }

                Text(site.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)

                Text(site.arabicName)
                    .font(.title3)
                    .foregroundColor(Theme.Colors.gold)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.clear, Theme.Colors.darkBackground.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 280)
    }

    // MARK: - Site Header
    private var siteHeader: some View {
        Text(site.shortDescription)
            .font(.body)
            .foregroundColor(.white.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(SiteTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                            Text(tab.title)
                        }
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundColor(selectedTab == tab ? Theme.Colors.gold : .white.opacity(0.5))

                        Rectangle()
                            .fill(selectedTab == tab ? Theme.Colors.gold : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Explore Content
    private var exploreContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let subLocations = site.subLocations, !subLocations.isEmpty {
                Text("MYSTERIES TO UNLOCK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
                    .tracking(2)

                Text("\(subLocations.count) \(subLocations.count == 1 ? "Mystery Awaits" : "Mysteries Await")")
                    .font(.headline)
                    .foregroundColor(.white)

                LazyVStack(spacing: 12) {
                    ForEach(subLocations) { subLocation in
                        NavigationLink(destination: StoryCardsView(subLocation: subLocation)) {
                            MysteryCard(subLocation: subLocation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(Theme.Colors.gold)
                    Text("Stories coming soon...")
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }

    // MARK: - Discover Content
    private var discoverContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Discovery Key Section
            DiscoveryKeySection(site: site)

            // How to Get There Section
            DirectionsSection(site: site)
        }
    }

    // MARK: - Info Content
    private var infoContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoCard(title: "PLAN YOUR VISIT", icon: "clock") {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Duration", value: site.visitInfo.estimatedDuration)
                    InfoRow(label: "Best Time", value: site.visitInfo.bestTimeToVisit)
                }
            }

            InfoCard(title: "TIPS", icon: "lightbulb") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(site.visitInfo.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.Colors.gold)
                                .font(.caption)
                            Text(tip)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }

            InfoCard(title: "ARABIC PHRASES", icon: "text.bubble") {
                VStack(spacing: 12) {
                    ForEach(site.visitInfo.arabicPhrases) { phrase in
                        PhraseRow(phrase: phrase)
                    }
                }
            }
        }
    }
}

// MARK: - Site Tab
enum SiteTab: CaseIterable {
    case explore, discover, info

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .discover: return "Discover"
        case .info: return "Visit Info"
        }
    }

    var icon: String {
        switch self {
        case .explore: return "book.fill"
        case .discover: return "mappin.circle.fill"
        case .info: return "info.circle"
        }
    }
}

// MARK: - Tag Badge
struct TagBadge: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
        .foregroundColor(.white)
    }
}

// MARK: - Mystery Card (Explore tab - Knowledge Key only)
struct MysteryCard: View {
    let subLocation: SubLocation
    @EnvironmentObject var viewModel: HomeViewModel

    private var hasKnowledgeKey: Bool {
        viewModel.hasScholarBadge(for: subLocation.id)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [
                            Theme.Colors.gold.opacity(hasKnowledgeKey ? 0.5 : 0.3),
                            Theme.Colors.sand.opacity(hasKnowledgeKey ? 0.6 : 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                Image(systemName: mysteryIcon)
                    .font(.system(size: 30))
                    .foregroundColor(Theme.Colors.gold.opacity(0.7))
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 6) {
                Text(subLocation.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subLocation.shortDescription)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()

            // Knowledge Key icon (turns gold when earned)
            Image(systemName: "key.fill")
                .font(.title2)
                .foregroundColor(hasKnowledgeKey ? Theme.Colors.gold : Theme.Colors.gold.opacity(0.4))
        }
        .padding()
        .background(Color.white.opacity(hasKnowledgeKey ? 0.08 : 0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    hasKnowledgeKey ? Theme.Colors.gold.opacity(0.3) : Theme.Colors.gold.opacity(0.2),
                    lineWidth: 1
                )
        )
    }

    private var mysteryIcon: String {
        let name = subLocation.name.lowercased()
        if name.contains("pyramid") { return "triangle.fill" }
        if name.contains("sphinx") { return "pawprint.fill" }
        if name.contains("temple") { return "building.columns.fill" }
        if name.contains("tomb") { return "square.stack.3d.down.right.fill" }
        if name.contains("museum") { return "building.fill" }
        if name.contains("boat") { return "sailboat.fill" }
        if name.contains("hall") { return "rectangle.split.3x3.fill" }
        return "star.fill"
    }
}

// MARK: - Discovery Key Section (Discover tab)
struct DiscoveryKeySection: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    private var hasDiscoveryKey: Bool {
        viewModel.hasExplorerBadge(for: site.id)
    }

    private var canUpgradeWithLocation: Bool {
        viewModel.selfReportedSites.contains(site.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DISCOVERY KEY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.gold)
                .tracking(2)

            VStack(spacing: 16) {
                // Status display
                HStack(spacing: 16) {
                    // Discovery Key icon
                    ZStack {
                        Circle()
                            .fill(hasDiscoveryKey ? Color.green.opacity(0.2) : Theme.Colors.gold.opacity(0.2))
                            .frame(width: 70, height: 70)

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(hasDiscoveryKey ? .green : Theme.Colors.gold)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        if hasDiscoveryKey && !canUpgradeWithLocation {
                            Text("Visit Verified!")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text("You've been to \(site.name)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        } else if canUpgradeWithLocation {
                            Text("Visited")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.gold)
                            Text("Verify location for +20 bonus!")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Text("Earn Your Discovery Key")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()
                }

                // Action buttons
                if !hasDiscoveryKey || canUpgradeWithLocation {
                    VStack(spacing: 12) {
                        Button(action: verifyWithLocation) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Verify My Location")
                                Spacer()
                                Text(canUpgradeWithLocation ? "+20 bonus" : "+50")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding()
                            .background(Theme.Colors.gold)
                            .cornerRadius(12)
                        }

                        if !hasDiscoveryKey {
                            Button(action: selfReport) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                    Text("Mark as Visited")
                                    Spacer()
                                    Text("+30")
                                        .font(.caption)
                                        .foregroundColor(Theme.Colors.gold.opacity(0.6))
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.Colors.gold)
                                .padding()
                                .background(Theme.Colors.gold.opacity(0.15))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(hasDiscoveryKey ? Color.green.opacity(0.3) : Theme.Colors.gold.opacity(0.2), lineWidth: 1)
            )
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func verifyWithLocation() {
        // Check if permission is denied
        if locationManager.isDenied {
            alertTitle = "Location Access Denied"
            alertMessage = "Please enable location access in Settings to verify your visit, or use 'Mark as Visited' instead."
            showingAlert = true
            return
        }

        // Request permission if not yet determined
        if !locationManager.isAuthorized {
            locationManager.requestPermission()
            // Show message that they need to grant permission
            alertTitle = "Location Permission Needed"
            alertMessage = "Please allow location access when prompted, then try again."
            showingAlert = true
            return
        }

        // Use callback-based location request
        locationManager.requestLocationWithCallback { [self] (userLocation: CLLocation?) in
            let result = viewModel.verifyAndAwardExplorerBadge(for: site, userLocation: userLocation)
            alertTitle = result.0 ? "Discovery Key Unlocked!" : "Oops!"
            alertMessage = result.1
            showingAlert = true
        }
    }

    private func selfReport() {
        let result = viewModel.selfReportVisit(for: site.id)
        alertTitle = result.0 ? "Discovery Key Unlocked!" : "Hmm..."
        alertMessage = result.1
        showingAlert = true
    }
}

// MARK: - Directions Section (Discover tab)
struct DirectionsSection: View {
    let site: Site

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HOW TO GET THERE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.gold)
                .tracking(2)

            VStack(spacing: 12) {
                // Location info
                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.gold)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(site.city.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("Coordinates: \(site.coordinates.latitude, specifier: "%.4f"), \(site.coordinates.longitude, specifier: "%.4f")")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Google Maps button
                Button(action: openInGoogleMaps) {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        Text("Open in Google Maps")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)
                }

                // Apple Maps button
                Button(action: openInAppleMaps) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Open in Apple Maps")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.Colors.gold.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private func openInGoogleMaps() {
        let urlString = "https://www.google.com/maps/dir/?api=1&destination=\(site.coordinates.latitude),\(site.coordinates.longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func openInAppleMaps() {
        let urlString = "http://maps.apple.com/?daddr=\(site.coordinates.latitude),\(site.coordinates.longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Info Card
struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.Colors.gold)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
                    .tracking(1)
            }
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.gold.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .font(.subheadline)
    }
}

// MARK: - Phrase Row
struct PhraseRow: View {
    let phrase: ArabicPhrase

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(phrase.english)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            Text(phrase.arabic)
                .font(.title3)
                .foregroundColor(Theme.Colors.gold)
            Text(phrase.pronunciation)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .italic()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
    }
}

// MARK: - Proximity Prompt (shown when user is near site)
struct ProximityPrompt: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)

                Text("You're here! Tap to earn your Discovery Key")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(Theme.Colors.gold)
            }
            .padding(12)
            .background(Color.green.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        SiteDetailView(site: PreviewData.sites[0])
    }
}
