import SwiftUI

/// App-wide theme constants
enum Theme {
    // MARK: - Colors
    enum Colors {
        /// Egyptian gold - primary accent color
        static let gold = Color(hex: "d4af37")
        /// Dark background - primary
        static let darkBackground = Color(hex: "1a1a2e")
        /// Dark background - secondary
        static let darkBackgroundSecondary = Color(hex: "16213e")
        /// Dark background - deep
        static let darkBackgroundDeep = Color(hex: "0f0f1a")
        /// Card/surface background
        static let cardBackground = Color.white.opacity(0.1)
        /// Subtle card background
        static let cardBackgroundSubtle = Color.white.opacity(0.05)
        /// Elevated card background
        static let cardBackgroundElevated = Color.white.opacity(0.12)
        /// Sand/brown accent
        static let sand = Color(hex: "8b7355")
        /// Quiz blue
        static let quizBlue = Color(hex: "4da6ff")
        /// Success green
        static let success = Color(hex: "34c759")
        /// Warning orange
        static let warning = Color(hex: "ff9500")

        // MARK: - Era Colors (for Timeline)
        static let eraPreDynastic = Color(hex: "9b59b6")
        static let eraOldKingdom = gold
        static let eraMiddleKingdom = Color(hex: "f39c12")
        static let eraNewKingdom = Color(hex: "e74c3c")
        static let eraLatePeriod = Color(hex: "3498db")
        static let eraPtolemaic = Color(hex: "2ecc71")
        static let eraRoman = Color(hex: "e91e63")
        static let eraIslamic = Color(hex: "00bcd4")
        static let eraModern = Color(hex: "95a5a6")

        /// Get color for a specific era
        static func color(for era: Era) -> Color {
            switch era {
            case .preDynastic: return eraPreDynastic
            case .oldKingdom: return eraOldKingdom
            case .middleKingdom: return eraMiddleKingdom
            case .newKingdom: return eraNewKingdom
            case .latePeriod: return eraLatePeriod
            case .ptolemaic: return eraPtolemaic
            case .roman: return eraRoman
            case .islamic: return eraIslamic
            case .modern: return eraModern
            }
        }
    }

    // MARK: - Gradients
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Colors.darkBackground, Colors.darkBackgroundSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var storyBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Colors.darkBackground, Colors.darkBackgroundDeep],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [Colors.gold.opacity(0.35), Colors.sand.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var subtleGoldGradient: LinearGradient {
        LinearGradient(
            colors: [Colors.gold.opacity(0.15), Colors.gold.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let pill: CGFloat = 100
    }

    // MARK: - Animation
    enum Animation {
        static let quick: SwiftUI.Animation = .easeOut(duration: 0.15)
        static let normal: SwiftUI.Animation = .easeInOut(duration: 0.25)
        static let smooth: SwiftUI.Animation = .spring(response: 0.35, dampingFraction: 0.7)
        static let bouncy: SwiftUI.Animation = .spring(response: 0.4, dampingFraction: 0.6)
    }
}

/// Reusable gradient background view
struct GradientBackground: View {
    var body: some View {
        Theme.backgroundGradient
            .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        GradientBackground()
        VStack(spacing: 20) {
            Text("Theme Preview")
                .foregroundColor(.white)
            Circle()
                .fill(Theme.Colors.gold)
                .frame(width: 50, height: 50)
            Circle()
                .fill(Theme.Colors.quizBlue)
                .frame(width: 50, height: 50)
        }
    }
}
