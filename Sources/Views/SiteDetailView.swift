import SwiftUI

struct SiteDetailView: View {
    let site: Site
    @State private var selectedTab: SiteTab = .explore

    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1a1a2e")
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
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Multi-layer gradient background for depth
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "d4af37").opacity(0.5), Color(hex: "8b7355").opacity(0.3), Color(hex: "1a1a2e")],
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
                    .stroke(Color(hex: "d4af37").opacity(0.1), lineWidth: 1)
                }
            }
            .frame(height: 280)

            // Large decorative icon
            VStack {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color(hex: "d4af37").opacity(0.15))
                        .frame(width: 150, height: 150)
                        .blur(radius: 20)

                    Image(systemName: site.placeType.icon)
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(Color(hex: "d4af37").opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -20)

            // Info overlay with gradient backdrop
            VStack(alignment: .leading, spacing: 8) {
                Spacer()

                // Tags
                HStack(spacing: 8) {
                    TagBadge(text: site.era.shortName, icon: "calendar")
                    TagBadge(text: site.placeType.rawValue, icon: site.placeType.icon)
                    TagBadge(text: site.city.rawValue, icon: "mappin")
                }

                Text(site.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)

                Text(site.arabicName)
                    .font(.title3)
                    .foregroundColor(Color(hex: "d4af37"))
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.clear, Color(hex: "1a1a2e").opacity(0.8)],
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
                        .foregroundColor(selectedTab == tab ? Color(hex: "d4af37") : .white.opacity(0.5))

                        Rectangle()
                            .fill(selectedTab == tab ? Color(hex: "d4af37") : Color.clear)
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
                Text("DISCOVER")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "d4af37"))
                    .tracking(2)

                Text("\(subLocations.count) places to explore")
                    .font(.headline)
                    .foregroundColor(.white)

                LazyVStack(spacing: 12) {
                    ForEach(subLocations) { subLocation in
                        NavigationLink(destination: StoryCardsView(subLocation: subLocation)) {
                            SubLocationCard(subLocation: subLocation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(Color(hex: "d4af37"))
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
                                .foregroundColor(Color(hex: "d4af37"))
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
    @EnvironmentObject var viewModel: HomeViewModel

    private var isCompleted: Bool {
        viewModel.isSubLocationCompleted(subLocation.id)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Enhanced image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [
                            Color(hex: "d4af37").opacity(isCompleted ? 0.5 : 0.3),
                            Color(hex: "8b7355").opacity(isCompleted ? 0.6 : 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                // Egyptian-themed icon based on name
                Image(systemName: subLocationIcon)
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: "d4af37").opacity(0.7))

                // Completed badge
                if isCompleted {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                                .background(Circle().fill(Color(hex: "1a1a2e")).padding(-2))
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(subLocation.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    if isCompleted {
                        Text("✓")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Text(subLocation.shortDescription)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.caption2)
                    Text("\(subLocation.storyCards.count) story cards")
                        .font(.caption2)
                }
                .foregroundColor(Color(hex: "d4af37"))
            }

            Spacer()

            Image(systemName: isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                .font(.title)
                .foregroundColor(isCompleted ? .green : Color(hex: "d4af37"))
        }
        .padding()
        .background(Color.white.opacity(isCompleted ? 0.08 : 0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color.green.opacity(0.3) : Color(hex: "d4af37").opacity(0.2), lineWidth: 1)
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
                    .foregroundColor(Color(hex: "d4af37"))
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "d4af37"))
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
                .stroke(Color(hex: "d4af37").opacity(0.1), lineWidth: 1)
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
                .foregroundColor(Color(hex: "d4af37"))
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

#Preview {
    NavigationStack {
        SiteDetailView(site: SampleData.sites[0])
    }
}
