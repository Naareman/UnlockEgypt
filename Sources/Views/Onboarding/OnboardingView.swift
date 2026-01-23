import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Theme.Colors.darkBackground,
                    Theme.Colors.darkBackgroundDeep
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < 2 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(height: 44)

                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    WelcomePage()
                        .tag(0)

                    // Page 2: How it works
                    HowItWorksPage()
                        .tag(1)

                    // Page 3: Level up
                    LevelUpPage()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                // Page indicators
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Theme.Colors.gold : Color.white.opacity(0.2))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // Action button
                Button(action: {
                    if currentPage < 2 {
                        withAnimation(.spring(response: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentPage == 2 ? "Start Exploring" : "Next")
                            .fontWeight(.semibold)
                        if currentPage < 2 {
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.Colors.gold)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation(.easeOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Animated icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.1))
                    .frame(width: 200, height: 200)

                // Middle ring
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.2))
                    .frame(width: 140, height: 140)

                // Icon
                Image(systemName: "key.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(Theme.Colors.gold)
            }

            VStack(spacing: 12) {
                Text("UNLOCK")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)
                + Text(" EGYPT")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(Theme.Colors.gold)

                Text("5,000 years of secrets await")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - How It Works Page
struct HowItWorksPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Earn Keys")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 24) {
                // Knowledge Key
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.gold.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Image(systemName: "key.fill")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.gold)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Knowledge Key")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Read stories & learn secrets")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()
                }
                .padding(.horizontal, 40)

                // Discovery Key
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Image(systemName: "key.horizontal.fill")
                            .font(.title2)
                            .foregroundColor(.cyan)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discovery Key")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Visit sites in person")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()
                }
                .padding(.horizontal, 40)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Level Up Page
struct LevelUpPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Crown icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.1))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(Theme.Colors.gold.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.Colors.gold)
            }

            VStack(spacing: 16) {
                Text("Rise to Pharaoh")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Earn points • Unlock achievements")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))

                // Rank progression
                HStack(spacing: 4) {
                    ForEach(["Tourist", "Explorer", "Pharaoh"], id: \.self) { rank in
                        if rank != "Tourist" {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.3))
                        }
                        Text(rank)
                            .font(.caption)
                            .foregroundColor(rank == "Pharaoh" ? Theme.Colors.gold : .white.opacity(0.5))
                    }
                }
                .padding(.top, 8)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
