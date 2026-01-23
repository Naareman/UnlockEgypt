import SwiftUI

struct HistoryTimelineView: View {
    let sites: [Site]
    @State private var scrollTarget: Era? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("JOURNEY THROUGH TIME")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.gold)
                        .tracking(2)

                    Text("5,000 years of history")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                // Horizontal era selector (clickable)
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Era.allCases, id: \.self) { era in
                                TimelineEraPill(
                                    era: era,
                                    hasSites: !sites.filter { $0.era == era }.isEmpty
                                ) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        scrollTarget = era
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Vertical detailed timeline
                    ScrollViewReader { verticalProxy in
                        VStack(spacing: 0) {
                            ForEach(Era.allCases, id: \.self) { era in
                                TimelineEraRow(
                                    era: era,
                                    sites: sites.filter { $0.era == era },
                                    isLast: era == Era.allCases.last
                                )
                                .id(era)
                            }
                        }
                        .padding(.horizontal)
                        .onChange(of: scrollTarget) { _, newValue in
                            if let era = newValue {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    verticalProxy.scrollTo(era, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Timeline Era Pill (Clickable)
struct TimelineEraPill: View {
    let era: Era
    let hasSites: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Era indicator
                Circle()
                    .fill(hasSites ? eraColor : Color.white.opacity(0.2))
                    .frame(width: 14, height: 14)
                    .shadow(color: hasSites ? eraColor.opacity(0.5) : .clear, radius: 3)

                // Era name
                Text(era.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(hasSites ? .white : .white.opacity(0.4))
                    .frame(width: 70)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80)
        }

        // Connector line
        if era != Era.allCases.last {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 30, height: 2)
        }
    }

    private var eraColor: Color {
        Theme.Colors.color(for: era)
    }
}

// MARK: - Timeline Era Row (Vertical)
struct TimelineEraRow: View {
    let era: Era
    let sites: [Site]
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(sites.isEmpty ? Color.white.opacity(0.2) : Theme.Colors.gold)
                    .frame(width: 14, height: 14)
                    .shadow(color: sites.isEmpty ? .clear : Theme.Colors.gold.opacity(0.5), radius: 4)

                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 2)
                        .frame(minHeight: sites.isEmpty ? 60 : 80)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(era.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(era.yearRange)
                        .font(.caption)
                        .foregroundColor(Theme.Colors.gold)
                }

                if !sites.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(sites) { site in
                            NavigationLink(destination: SiteDetailView(site: site)) {
                                TimelineSiteCard(site: site)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    Text("No sites from this era yet")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                        .italic()
                }
            }
            .padding(.bottom, isLast ? 0 : 20)

            Spacer()
        }
    }
}

// MARK: - Timeline Site Card (Dark Theme)
struct TimelineSiteCard: View {
    let site: Site

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [Theme.Colors.gold.opacity(0.3), Theme.Colors.sand.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)

                Image(systemName: site.placeType.icon)
                    .font(.title3)
                    .foregroundColor(Theme.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 9))
                    Text("\(site.subLocations?.count ?? 0) places to explore")
                        .font(.caption2)
                }
                .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.gold.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ZStack {
            GradientBackground()
            HistoryTimelineView(sites: PreviewData.sites)
        }
    }
    .preferredColorScheme(.dark)
}
