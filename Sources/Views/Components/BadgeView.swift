import SwiftUI

// MARK: - Badge Types (Keys)
enum BadgeType {
    case scholar  // Knowledge Key
    case explorer // Discovery Key

    var icon: String {
        switch self {
        case .scholar: return "key.fill"
        case .explorer: return "mappin.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .scholar: return "Knowledge"
        case .explorer: return "Discovery"
        }
    }

    var color: Color {
        switch self {
        case .scholar: return Theme.Colors.gold
        case .explorer: return .green
        }
    }

    var description: String {
        switch self {
        case .scholar: return "Unlocked all secrets"
        case .explorer: return "Visited this site"
        }
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let type: BadgeType
    let isEarned: Bool
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 24
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 10
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: size.iconSize))
            if size != .small {
                Text(type.title)
                    .font(size == .large ? .caption : .caption2)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, size.padding + 2)
        .padding(.vertical, size.padding)
        .background(
            isEarned ? type.color.opacity(0.2) : Color.white.opacity(0.1)
        )
        .foregroundColor(
            isEarned ? type.color : .white.opacity(0.4)
        )
        .cornerRadius(size == .small ? 6 : 8)
        .overlay(
            RoundedRectangle(cornerRadius: size == .small ? 6 : 8)
                .stroke(isEarned ? type.color.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Dual Badge View (shows both badges side by side)
struct DualBadgeView: View {
    let hasScholar: Bool
    let hasExplorer: Bool
    var size: BadgeView.BadgeSize = .medium

    var body: some View {
        HStack(spacing: 6) {
            BadgeView(type: .scholar, isEarned: hasScholar, size: size)
            BadgeView(type: .explorer, isEarned: hasExplorer, size: size)
        }
    }
}

// MARK: - Completion Checkmark (only shows when both badges earned)
struct CompletionCheckmark: View {
    let isComplete: Bool

    var body: some View {
        if isComplete {
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold)
                    .frame(width: 20, height: 20)
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
        }
    }
}

// MARK: - Badge Progress View (for site detail)
struct BadgeProgressView: View {
    let site: Site
    @EnvironmentObject var viewModel: HomeViewModel

    private var scholarProgress: (earned: Int, total: Int) {
        guard let subs = site.subLocations else { return (0, 0) }
        let earned = subs.filter { viewModel.hasScholarBadge(for: $0.id) }.count
        return (earned, subs.count)
    }

    private var hasExplorer: Bool {
        viewModel.hasExplorerBadge(for: site.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Scholar progress
            HStack {
                BadgeView(type: .scholar, isEarned: scholarProgress.earned == scholarProgress.total && scholarProgress.total > 0)
                Spacer()
                if scholarProgress.total > 0 {
                    Text("\(scholarProgress.earned)/\(scholarProgress.total)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Explorer badge
            HStack {
                BadgeView(type: .explorer, isEarned: hasExplorer)
                Spacer()
                if hasExplorer {
                    Text("Verified")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Not visited")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.Colors.darkBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            DualBadgeView(hasScholar: true, hasExplorer: false)
            DualBadgeView(hasScholar: true, hasExplorer: true)
            DualBadgeView(hasScholar: false, hasExplorer: false)
            HStack {
                BadgeView(type: .scholar, isEarned: true, size: .small)
                BadgeView(type: .explorer, isEarned: false, size: .small)
            }
        }
    }
}
