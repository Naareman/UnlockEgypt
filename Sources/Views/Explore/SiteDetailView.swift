import SwiftUI

struct SiteDetailView: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var selectedTab: SiteTab = .explore

    private var isFavorite: Bool {
        viewModel.isFavorite(siteId: site.id)
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
                        tabSelector

                        switch selectedTab {
                        case .explore:
                            exploreContent
                        case .info:
                            infoContent
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleFavorite(siteId: site.id)
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .white)
                }

                Button(action: {
                    ShareService.shareSite(site)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
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
            // Explorer Badge Section
            ExplorerBadgeCard(site: site)

            if let subLocations = site.subLocations, !subLocations.isEmpty {
                Text("SECRETS TO UNLOCK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
                    .tracking(2)

                Text("\(subLocations.count) mysteries await")
                    .font(.headline)
                    .foregroundColor(.white)

                LazyVStack(spacing: 12) {
                    ForEach(subLocations) { subLocation in
                        NavigationLink(destination: StoryCardsView(subLocation: subLocation)) {
                            SubLocationCard(subLocation: subLocation, siteId: site.id)
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
    case explore, info

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .info: return "Visit Info"
        }
    }

    var icon: String {
        switch self {
        case .explore: return "eye"
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

// MARK: - Sub-Location Card
struct SubLocationCard: View {
    let subLocation: SubLocation
    let siteId: String
    @EnvironmentObject var viewModel: HomeViewModel

    private var hasScholar: Bool {
        viewModel.hasScholarBadge(for: subLocation.id)
    }

    private var hasExplorer: Bool {
        viewModel.hasExplorerBadge(for: siteId)
    }

    private var isFullyCompleted: Bool {
        hasScholar && hasExplorer
    }

    var body: some View {
        HStack(spacing: 14) {
            // Enhanced image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [
                            Theme.Colors.gold.opacity(isFullyCompleted ? 0.5 : (hasScholar ? 0.4 : 0.3)),
                            Theme.Colors.sand.opacity(isFullyCompleted ? 0.6 : (hasScholar ? 0.5 : 0.4))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                // Egyptian-themed icon based on name
                Image(systemName: subLocationIcon)
                    .font(.system(size: 30))
                    .foregroundColor(Theme.Colors.gold.opacity(0.7))

                // Completion checkmark (only when both badges earned)
                if isFullyCompleted {
                    VStack {
                        HStack {
                            Spacer()
                            CompletionCheckmark(isComplete: true)
                        }
                        Spacer()
                    }
                    .padding(4)
                }
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

                // Dual badge display
                HStack(spacing: 4) {
                    BadgeView(type: .scholar, isEarned: hasScholar, size: .small)
                    BadgeView(type: .explorer, isEarned: hasExplorer, size: .small)
                }
            }

            Spacer()

            // Status icon
            VStack {
                if isFullyCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                } else if hasScholar {
                    Image(systemName: "book.circle.fill")
                        .font(.title)
                        .foregroundColor(Theme.Colors.gold)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundColor(Theme.Colors.gold)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(isFullyCompleted ? 0.08 : 0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isFullyCompleted ? Color.green.opacity(0.3) :
                    (hasScholar ? Theme.Colors.gold.opacity(0.3) : Theme.Colors.gold.opacity(0.2)),
                    lineWidth: 1
                )
        )
    }

    private var subLocationIcon: String {
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

// MARK: - Discovery Key Card
struct ExplorerBadgeCard: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var pointsEarned = 0

    private var hasDiscoveryKey: Bool {
        viewModel.hasExplorerBadge(for: site.id)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "key.horizontal.fill")
                            .foregroundColor(hasDiscoveryKey ? .cyan : .white.opacity(0.6))
                        Text("DISCOVERY KEY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(hasDiscoveryKey ? .cyan : Theme.Colors.gold)
                            .tracking(1)
                    }

                    if hasDiscoveryKey {
                        Text("Site unlocked! You've been here.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Text("Unlock this site by visiting (+50 pts)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                if hasDiscoveryKey {
                    BadgeView(type: .explorer, isEarned: true, size: .large)
                } else {
                    Button(action: verifyVisit) {
                        HStack(spacing: 6) {
                            Image(systemName: "key.horizontal.fill")
                            Text("Unlock Site!")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.gold)
                        .cornerRadius(20)
                    }
                }
            }

            // Location status hint
            if !hasDiscoveryKey {
                HStack(spacing: 6) {
                    if locationManager.authorizationStatus == .authorizedWhenInUse ||
                       locationManager.authorizationStatus == .authorizedAlways {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Location ready to verify")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    } else {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Enable location for 50 pts, or self-report for 30 pts")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .padding()
        .background(
            hasDiscoveryKey ?
            Color.cyan.opacity(0.1) :
            Color.white.opacity(0.05)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    hasDiscoveryKey ? Color.cyan.opacity(0.3) : Theme.Colors.gold.opacity(0.2),
                    lineWidth: 1
                )
        )
        .onAppear {
            locationManager.requestPermission()
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            if pointsEarned == 0 && !hasDiscoveryKey {
                Button("Self-Report (+30 pts)") {
                    let result = viewModel.selfReportVisit(for: site.id)
                    if result.0 {
                        alertTitle = "Site Unlocked!"
                        alertMessage = result.1
                        pointsEarned = result.2
                        showingAlert = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            } else {
                Button("OK", role: .cancel) {}
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func verifyVisit() {
        let result = viewModel.verifyAndAwardExplorerBadge(for: site, userLocation: locationManager.location)

        alertTitle = result.0 ? "Discovery Key Unlocked!" : "Verification"
        alertMessage = result.1
        pointsEarned = result.2
        showingAlert = true
    }
}

#Preview {
    NavigationStack {
        SiteDetailView(site: PreviewData.sites[0])
    }
}
