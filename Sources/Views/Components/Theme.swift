import SwiftUI

/// App-wide theme constants
enum Theme {
    // MARK: - Colors
    enum Colors {
        static let gold = Color(hex: "d4af37")
        static let darkBackground = Color(hex: "1a1a2e")
        static let darkBackgroundSecondary = Color(hex: "16213e")
        static let cardBackground = Color.white.opacity(0.1)
    }

    // MARK: - Gradients
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Colors.darkBackground, Colors.darkBackgroundSecondary],
            startPoint: .top,
            endPoint: .bottom
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
        Text("Hello Egypt!")
            .foregroundColor(.white)
    }
}
