import SwiftUI

struct HistoryTimelineView: View {
    let sites: [Site]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Journey Through Time")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Era.allCases, id: \.self) { era in
                        TimelineEraSection(
                            era: era,
                            sites: sites.filter { $0.era == era }
                        )
                    }
                }
            }

            // Vertical detailed timeline
            VStack(spacing: 0) {
                ForEach(Era.allCases, id: \.self) { era in
                    TimelineEraRow(
                        era: era,
                        sites: sites.filter { $0.era == era },
                        isLast: era == Era.allCases.last
                    )
                }
            }
        }
    }
}

// MARK: - Timeline Era Section (Horizontal)
struct TimelineEraSection: View {
    let era: Era
    let sites: [Site]

    var body: some View {
        VStack(spacing: 8) {
            // Era indicator
            Circle()
                .fill(eraColor)
                .frame(width: 16, height: 16)

            // Era name
            Text(era.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .frame(width: 80)
                .multilineTextAlignment(.center)

            // Year range
            Text(era.yearRange)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
                .frame(width: 80)

            // Sites count
            if !sites.isEmpty {
                Text("\(sites.count) sites")
                    .font(.caption2)
                    .foregroundColor(.accentColor)
            }
        }
        .frame(width: 100)

        // Connector line
        if era != Era.allCases.last {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 2)
        }
    }

    private var eraColor: Color {
        switch era {
        case .preDynastic: return .purple
        case .oldKingdom: return .orange
        case .middleKingdom: return .yellow
        case .newKingdom: return .red
        case .latePeriod: return .blue
        case .ptolemaic: return .green
        case .roman: return .pink
        case .islamic: return .teal
        case .modern: return .gray
        }
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
                    .fill(sites.isEmpty ? Color.secondary.opacity(0.3) : Color.accentColor)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 2)
                        .frame(minHeight: 60)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(era.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(era.yearRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !sites.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(sites) { site in
                            NavigationLink(destination: SiteDetailView(site: site)) {
                                TimelineSiteCard(site: site)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.bottom, isLast ? 0 : 16)

            Spacer()
        }
    }
}

// MARK: - Timeline Site Card
struct TimelineSiteCard: View {
    let site: Site

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.orange.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: site.placeType.icon)
                        .font(.caption)
                        .foregroundColor(.orange)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(site.name)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("\(site.subLocations?.count ?? 0) places to see")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            HistoryTimelineView(sites: SampleData.sites)
                .padding()
        }
    }
}
