import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "key.fill",
            title: "Unlock Ancient Secrets",
            subtitle: "Discover 5,000 years of Egyptian history through immersive stories and hidden knowledge.",
            highlightText: "Welcome to Unlock Egypt"
        ),
        OnboardingPage(
            icon: "book.fill",
            title: "Knowledge Keys",
            subtitle: "Complete stories at each location to earn Knowledge Keys. Learn the secrets that make each site legendary.",
            highlightText: "🗝️ Read • Learn • Unlock"
        ),
        OnboardingPage(
            icon: "location.fill",
            title: "Discovery Keys",
            subtitle: "Visit sites in person to earn Discovery Keys. Your location unlocks bonus points and proves your adventure.",
            highlightText: "🗝️ Visit • Verify • Unlock"
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Rise to Pharaoh",
            subtitle: "Earn points, unlock achievements, and climb the ranks from Tourist to Pharaoh. Your journey awaits!",
            highlightText: "Tourist → Traveler → Explorer → Historian → Archaeologist → Pharaoh"
        )
    ]

    var body: some View {
        ZStack {
            Theme.Colors.darkBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Theme.Colors.gold : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                // Action button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Start Exploring" : "Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.Colors.gold)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let highlightText: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.15))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(Theme.Colors.gold.opacity(0.25))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Theme.Colors.gold)
            }

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(page.highlightText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.gold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
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
