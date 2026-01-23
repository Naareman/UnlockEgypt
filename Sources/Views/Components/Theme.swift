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
        /// Sand/brown accent
        static let sand = Color(hex: "8b7355")
        /// Quiz blue
        static let quizBlue = Color(hex: "4da6ff")

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
