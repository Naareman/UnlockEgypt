import SwiftUI

// MARK: - Press Effect Button Style
/// A button style that provides a press effect without blocking taps
struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Press Effect Modifier (for non-button views)
struct PressEffect: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(Theme.Animation.quick, value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

extension View {
    func pressEffect() -> some View {
        modifier(PressEffect())
    }
}

// MARK: - Shimmer Loading Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.1),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + phase * geo.size.width * 2)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Skeleton Loading Card
struct SkeletonCard: View {
    var height: CGFloat = 100

    var body: some View {
        HStack(spacing: 14) {
            // Image placeholder
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .fill(Color.white.opacity(0.08))
                .frame(width: 80, height: 80)

            // Text placeholders
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 16)
                    .frame(maxWidth: 140)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 12)
                    .frame(maxWidth: 100)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.04))
                    .frame(height: 10)
                    .frame(maxWidth: 180)
            }

            Spacer()
        }
        .padding()
        .background(Theme.Colors.cardBackgroundSubtle)
        .cornerRadius(Theme.Radius.lg)
        .shimmer()
    }
}

// MARK: - Loading Dots
struct LoadingDots: View {
    @State private var activeIndex = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Theme.Colors.gold)
                    .frame(width: 8, height: 8)
                    .scaleEffect(activeIndex == index ? 1.3 : 0.8)
                    .opacity(activeIndex == index ? 1 : 0.4)
            }
        }
        .onReceive(timer) { _ in
            withAnimation(Theme.Animation.quick) {
                activeIndex = (activeIndex + 1) % 3
            }
        }
    }
}

// MARK: - Glow Effect
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.4), radius: radius)
            .shadow(color: color.opacity(0.2), radius: radius * 2)
    }
}

extension View {
    func glow(color: Color = Theme.Colors.gold, radius: CGFloat = 8) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Card Style Modifier
struct CardStyle: ViewModifier {
    var isElevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(isElevated ? Theme.Colors.cardBackgroundElevated : Theme.Colors.cardBackground)
            .cornerRadius(Theme.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .stroke(Theme.Colors.gold.opacity(0.15), lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(elevated: Bool = false) -> some View {
        modifier(CardStyle(isElevated: elevated))
    }
}

#Preview {
    ZStack {
        GradientBackground()
        VStack(spacing: 24) {
            SkeletonCard()
            SkeletonCard()

            LoadingDots()

            Text("Glow Effect")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Theme.Colors.gold)
                .cornerRadius(12)
                .glow()
        }
        .padding()
    }
}
