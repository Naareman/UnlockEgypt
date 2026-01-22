import SwiftUI

struct SiteDetailView: View {
    let site: Site
    @State private var selectedTab: SiteTab = .explore

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                heroSection

                // Content
                VStack(spacing: 20) {
                    // Site info header
                    siteHeader

                    // Tab selector
                    tabSelector

                    // Tab content
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
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder gradient
            LinearGradient(
                colors: [.orange, .brown.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 250)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Info overlay
            VStack(alignment: .leading, spacing: 8) {
                Spacer()

                // Badges
                HStack(spacing: 8) {
                    TagBadge(text: site.era.shortName, icon: "calendar")
                    TagBadge(text: site.placeType.rawValue, icon: site.placeType.icon)
                    TagBadge(text: site.city.rawValue, icon: "mappin")
                }

                Text(site.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(site.arabicName)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .frame(height: 250)
    }

    // MARK: - Site Header
    private var siteHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(site.shortDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
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
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Explore Content (Sub-locations)
    private var exploreContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let subLocations = site.subLocations, !subLocations.isEmpty {
                Text("Things to See")
                    .font(.headline)

                LazyVStack(spacing: 12) {
                    ForEach(subLocations) { subLocation in
                        NavigationLink(destination: StoryCardsView(subLocation: subLocation)) {
                            SubLocationCard(subLocation: subLocation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                // Fallback for sites without sub-locations
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Content coming soon")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }

    // MARK: - Info Content
    private var infoContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Visit Info
            InfoSection(title: "Plan Your Visit", icon: "clock") {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Duration", value: site.visitInfo.estimatedDuration)
                    InfoRow(label: "Best Time", value: site.visitInfo.bestTimeToVisit)
                }
            }

            // Tips
            InfoSection(title: "Tips", icon: "lightbulb") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(site.visitInfo.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(tip)
                                .font(.subheadline)
                        }
                    }
                }
            }

            // Arabic Phrases
            InfoSection(title: "Useful Arabic Phrases", icon: "text.bubble") {
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
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .foregroundColor(.white)
    }
}

// MARK: - Sub-Location Card
struct SubLocationCard: View {
    let subLocation: SubLocation

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    colors: [.orange.opacity(0.5), .brown.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(subLocation.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subLocation.shortDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "rectangle.stack")
                        .font(.caption2)
                    Text("\(subLocation.storyCards.count) cards")
                        .font(.caption2)
                }
                .foregroundColor(.accentColor)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

// MARK: - Info Section
struct InfoSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
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
            Text(phrase.arabic)
                .font(.title3)
            Text(phrase.pronunciation)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        SiteDetailView(site: SampleData.sites[0])
    }
}
