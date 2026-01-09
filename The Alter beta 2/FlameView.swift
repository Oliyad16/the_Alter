import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Flame Color Themes
enum FlameColorTheme: String, CaseIterable, Identifiable, Codable {
    case classic = "classic"
    case blue = "blue"
    case pink = "pink"
    case green = "green"
    case white = "white"
    case purple = "purple"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic Fire"
        case .blue: return "Sacred Blue"
        case .pink: return "Divine Rose"
        case .green: return "Living Hope"
        case .white: return "Holy Light"
        case .purple: return "Royal Flame"
        }
    }

    var primaryColors: [Color] {
        switch self {
        case .classic:
            return [Color.altarRed, Color.altarOrange, Color.altarYellow]
        case .blue:
            return [Color.blue, Color.cyan, Color.mint]
        case .pink:
            return [Color.pink, Color.purple.opacity(0.8), Color.white.opacity(0.9)]
        case .green:
            return [Color.green, Color.mint, Color.yellow.opacity(0.8)]
        case .white:
            return [Color.white, Color.gray.opacity(0.3), Color.clear]
        case .purple:
            return [Color.purple, Color.indigo, Color.pink.opacity(0.7)]
        }
    }

    var secondaryColors: [Color] {
        switch self {
        case .classic:
            return [Color.altarOrange, Color.altarYellow, Color.white.opacity(0.6)]
        case .blue:
            return [Color.cyan, Color.mint, Color.blue.opacity(0.6)]
        case .pink:
            return [Color.purple.opacity(0.6), Color.white.opacity(0.8), Color.pink.opacity(0.4)]
        case .green:
            return [Color.mint, Color.yellow.opacity(0.6), Color.green.opacity(0.7)]
        case .white:
            return [Color.gray.opacity(0.2), Color.clear, Color.white.opacity(0.3)]
        case .purple:
            return [Color.indigo, Color.pink.opacity(0.5), Color.purple.opacity(0.6)]
        }
    }

    var coreColors: [Color] {
        switch self {
        case .classic:
            return [Color.white, Color.altarYellow, Color.altarOrange]
        case .blue:
            return [Color.white, Color.cyan, Color.blue.opacity(0.7)]
        case .pink:
            return [Color.white, Color.pink, Color.purple.opacity(0.5)]
        case .green:
            return [Color.white, Color.mint, Color.green.opacity(0.6)]
        case .white:
            return [Color.white, Color.gray.opacity(0.1), Color.clear]
        case .purple:
            return [Color.white, Color.indigo, Color.purple.opacity(0.7)]
        }
    }

    var glowColor: Color {
        switch self {
        case .classic: return Color.altarOrange
        case .blue: return Color.cyan
        case .pink: return Color.pink
        case .green: return Color.mint
        case .white: return Color.white
        case .purple: return Color.indigo
        }
    }
}

// MARK: - Flame Levels
enum FlameLevel: Int, CaseIterable {
    case spark = 1
    case candle = 2
    case torch = 3
    case bonfire = 4
    case sacredFire = 5

    var displayName: String {
        switch self {
        case .spark: return "Spark"
        case .candle: return "Candle Flame"
        case .torch: return "Sacred Torch"
        case .bonfire: return "Holy Bonfire"
        case .sacredFire: return "Sacred Fire"
        }
    }

    var description: String {
        switch self {
        case .spark: return "A small beginning"
        case .candle: return "Gentle and steady"
        case .torch: return "Growing stronger"
        case .bonfire: return "Burning bright"
        case .sacredFire: return "Consuming fire"
        }
    }

    var intensityRange: ClosedRange<Double> {
        switch self {
        case .spark: return 0.0...0.2
        case .candle: return 0.2...0.4
        case .torch: return 0.4...0.6
        case .bonfire: return 0.6...0.8
        case .sacredFire: return 0.8...1.0
        }
    }

    static func from(intensity: Double) -> FlameLevel {
        if intensity >= 0.8 { return .sacredFire }
        if intensity >= 0.6 { return .bonfire }
        if intensity >= 0.4 { return .torch }
        if intensity >= 0.2 { return .candle }
        return .spark
    }
}

// MARK: - FlameView
struct FlameView: View {
    var intensity: Double // 0.0 ... 1.0
    var interactionEnabled: Bool = true
    var colorTheme: FlameColorTheme = .classic

    @State private var floatOffset: CGFloat = 0
    @State private var shimmer: Double = 0
    @State private var particleOffset: CGFloat = 0
    @State private var innerGlow: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var isAnimating = true

    private var flameLevel: FlameLevel {
        FlameLevel.from(intensity: intensity)
    }

    private var size: CGFloat { 100 + CGFloat(intensity) * 60 }

    var body: some View {
        ZStack {
            // Background glow
            backgroundGlow

            // Main flame body
            mainFlame

            // Inner flame details
            innerFlameEffects

            // Particle effects for higher levels
            if flameLevel.rawValue >= 3 {
                particleEffects
            }

            // Sacred fire crown effect
            if flameLevel == .sacredFire {
                crownEffect
            }
        }
        .scaleEffect(pulseScale)
        .onAppear { startAnimations() }
        .onTapGesture {
            if interactionEnabled {
                tapInteraction()
            }
        }
        .accessibilityLabel("\(flameLevel.displayName) - \(flameLevel.description)")
        .accessibilityValue("Intensity: \(Int(intensity * 100))%")
    }

    // MARK: - Visual Components
    @ViewBuilder
    private var backgroundGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        colorTheme.glowColor.opacity(0.4),
                        colorTheme.glowColor.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: size * 0.3,
                    endRadius: size * 1.2
                )
            )
            .frame(width: size * 2, height: size * 2)
            .blur(radius: 12 + intensity * 20)
    }

    @ViewBuilder
    private var mainFlame: some View {
        ZStack {
            // Primary flame shape
            Circle()
                .fill(primaryGradient)
                .frame(width: size, height: size)
                .blur(radius: 4 + intensity * 8)
                .overlay(
                    Circle()
                        .strokeBorder(
                            Color.white.opacity(0.1 + 0.4 * intensity),
                            lineWidth: 1 + intensity * 2
                        )
                )
                .shadow(
                    color: colorTheme.glowColor.opacity(0.3 + intensity * 0.5),
                    radius: 15 + intensity * 30,
                    x: 0,
                    y: 0
                )

            // Secondary flame layer for depth
            Circle()
                .fill(secondaryGradient)
                .frame(width: size * 0.8, height: size * 0.8)
                .blur(radius: 2 + intensity * 4)
                .opacity(0.7 + intensity * 0.3)
        }
        .offset(y: floatOffset)
    }

    @ViewBuilder
    private var innerFlameEffects: some View {
        ZStack {
            // Core flame
            Circle()
                .fill(coreGradient)
                .frame(width: size * 0.6, height: size * 0.6)
                .blur(radius: 1 + intensity * 3)
                .opacity(0.6 + 0.4 * sin(shimmer))

            // Inner glow pulse
            Circle()
                .stroke(
                    Color.white.opacity(0.2 + 0.3 * intensity),
                    lineWidth: 0.5 + intensity * 1.5
                )
                .frame(
                    width: size * CGFloat(0.4 + 0.1 * sin(innerGlow)),
                    height: size * CGFloat(0.4 + 0.1 * sin(innerGlow))
                )
                .blur(radius: 2)
        }
        .offset(y: floatOffset)
    }

    @ViewBuilder
    private var particleEffects: some View {
        ForEach(0..<6, id: \.self) { index in
            Circle()
                .fill(colorTheme.glowColor.opacity(0.3 + 0.2 * Double(index) / 6))
                .frame(width: 4 + CGFloat(index) * 2, height: 4 + CGFloat(index) * 2)
                .offset(
                    x: CGFloat.random(in: -size * 0.4...size * 0.4),
                    y: -size * 0.3 + particleOffset - CGFloat(index) * 8
                )
                .blur(radius: 2)
                .opacity(0.6)
        }
    }

    @ViewBuilder
    private var crownEffect: some View {
        ForEach(0..<8, id: \.self) { index in
            Circle()
                .fill(colorTheme.glowColor.opacity(0.4))
                .frame(width: 6, height: 6)
                .offset(
                    x: cos(Double(index) * .pi / 4) * Double(size * 0.6),
                    y: sin(Double(index) * .pi / 4) * Double(size * 0.6) - Double(size * 0.2)
                )
                .blur(radius: 3)
        }
    }

    // MARK: - Gradients
    private var primaryGradient: LinearGradient {
        LinearGradient(
            colors: colorTheme.primaryColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var secondaryGradient: LinearGradient {
        LinearGradient(
            colors: colorTheme.secondaryColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var coreGradient: RadialGradient {
        RadialGradient(
            colors: colorTheme.coreColors,
            center: .center,
            startRadius: 0,
            endRadius: size * 0.3
        )
    }

    // MARK: - Animations
    private func startAnimations() {
        // Floating animation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            floatOffset = -6
        }

        // Shimmer animation
        withAnimation(.easeInOut(duration: 2).repeatForever()) {
            shimmer = .pi * 2
        }

        // Inner glow animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
            innerGlow = .pi * 2
        }

        // Particle animation
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            particleOffset = -20
        }

        // Pulse animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.0 + 0.05 * intensity
        }
    }

    private func tapInteraction() {
        HapticManager.shared.trigger(.medium)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            floatOffset = -12
            pulseScale = 1.15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                floatOffset = -6
                pulseScale = 1.0 + 0.05 * intensity
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        HStack(spacing: 30) {
            FlameView(intensity: 0.3, colorTheme: .classic)
                .frame(height: 100)
            FlameView(intensity: 0.5, colorTheme: .blue)
                .frame(height: 100)
            FlameView(intensity: 0.7, colorTheme: .pink)
                .frame(height: 100)
        }
        HStack(spacing: 30) {
            FlameView(intensity: 0.6, colorTheme: .green)
                .frame(height: 100)
            FlameView(intensity: 0.8, colorTheme: .white)
                .frame(height: 100)
            FlameView(intensity: 0.95, colorTheme: .purple)
                .frame(height: 100)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.altarBlack)
}
