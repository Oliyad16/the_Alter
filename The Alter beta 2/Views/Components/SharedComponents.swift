import SwiftUI

// MARK: - Animated Card
struct AnimatedCard<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    @State private var hasAppeared = false
    var delay: Double = 0

    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.delay = delay
    }

    var body: some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .animation(AltarAnimations.staggered(index: Int(delay * 20)), value: hasAppeared)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    hasAppeared = true
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(AltarAnimations.cardPress) { isPressed = true }
                    }
                    .onEnded { _ in
                        withAnimation(AltarAnimations.cardPress) { isPressed = false }
                    }
            )
    }
}

// MARK: - Glowing Circle (for Prayer View) - Fire Colors
struct GlowingCircle: View {
    var size: CGFloat = 150
    var color: Color = .altarRed
    @State private var glowIntensity: CGFloat = 0.3

    var body: some View {
        ZStack {
            // Outer glow layers - fire gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.altarOrange.opacity(glowIntensity * 0.5), Color.altarRed.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)

            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.altarOrange.opacity(glowIntensity), Color.altarRed.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)

            // Inner bright core
            Circle()
                .fill(Color.altarYellow.opacity(glowIntensity + 0.2))
                .frame(width: size * 0.3, height: size * 0.3)
                .blur(radius: 10)
        }
        .onAppear {
            withAnimation(AltarAnimations.breathe) {
                glowIntensity = 0.6
            }
        }
    }
}

// MARK: - Progress Dots (for Onboarding)
struct ProgressDotsView: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.altarSoftGold : Color.white.opacity(0.3))
                    .frame(width: index == currentStep ? 12 : 8, height: index == currentStep ? 12 : 8)
                    .animation(AltarAnimations.bouncy, value: currentStep)
            }
        }
    }
}

// MARK: - Icon Badge (for notification counts)
struct IconBadge: View {
    let icon: String
    var count: Int = 0
    var size: CGFloat = 50

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: icon)
                .font(.system(size: size * 0.6))
                .foregroundColor(.altarSoftGold)
                .frame(width: size, height: size)

            if count > 0 {
                Text("\(min(count, 99))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(4)
                    .background(Circle().fill(Color.altarSoftGold))
                    .offset(x: 4, y: -4)
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AltarSpacing.large) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.altarSoftGold.opacity(0.6))
                .boldGlow(radius: 20)

            VStack(spacing: AltarSpacing.small) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(AltarBoldButtonStyle())
                .padding(.top)
            }
        }
        .padding()
    }
}

// MARK: - Time-based Greeting Icon - Fire Colors
struct GreetingIcon: View {
    @State private var glowAmount: CGFloat = 0.3

    private var iconName: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "sun.max.fill"
        case 12..<17: return "sun.min.fill"
        case 17..<21: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }

    private var iconColor: Color {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return .altarOrange
        case 12..<17: return .altarYellow
        case 17..<21: return .altarRed
        default: return .white.opacity(0.7)
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 48))
            .foregroundColor(iconColor)
            .shadow(color: iconColor.opacity(glowAmount), radius: 20, x: 0, y: 0)
            .shadow(color: iconColor.opacity(glowAmount * 0.5), radius: 40, x: 0, y: 0)
            .onAppear {
                withAnimation(AltarAnimations.glowPulse) {
                    glowAmount = 0.6
                }
            }
    }
}

// MARK: - Animated Chevron
struct AnimatedChevron: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(.white.opacity(0.4))
            .offset(x: offset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                ) {
                    offset = 4
                }
            }
    }
}

// MARK: - Gradient Border Card - Fire Colors
struct GradientBorderCard<Content: View>: View {
    let content: Content
    @State private var gradientRotation: Double = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.altarRed.opacity(0.6),
                                Color.altarOrange.opacity(0.3),
                                Color.altarRed.opacity(0.6)
                            ],
                            center: .center,
                            angle: .degrees(gradientRotation)
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.altarRed.opacity(0.15), radius: 20, x: 0, y: 8)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 8).repeatForever(autoreverses: false)
                ) {
                    gradientRotation = 360
                }
            }
    }
}

// MARK: - Slide In Modifier
struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(x: hasAppeared ? 0 : -30)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(AltarAnimations.slideIn) {
                        hasAppeared = true
                    }
                }
            }
    }
}

extension View {
    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay))
    }
}
