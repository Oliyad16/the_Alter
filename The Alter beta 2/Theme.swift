import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Flame Color Theme
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

    var description: String {
        switch self {
        case .classic: return "Warm fire colors"
        case .blue: return "Cool sacred tones"
        case .pink: return "Divine rose hues"
        case .green: return "Living hope green"
        case .white: return "Pure holy light"
        case .purple: return "Royal flame purple"
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

// MARK: - Colors (Fire & Night Aesthetic)
extension Color {
    // Primary accent: Altar Red (Fire)
    static let altarRed = Color(red: 223.0/255.0, green: 37.0/255.0, blue: 49.0/255.0)
    static let altarOrange = Color(red: 255.0/255.0, green: 140.0/255.0, blue: 0.0/255.0)
    static let altarYellow = Color(red: 255.0/255.0, green: 215.0/255.0, blue: 0.0/255.0)

    // Pure black background
    static let altarBlack = Color(red: 0, green: 0, blue: 0)
    static let altarDeepBlack = Color(red: 0, green: 0, blue: 0)
    static let altarDarkGray = Color(red: 18.0/255.0, green: 18.0/255.0, blue: 18.0/255.0)

    // Functional Colors
    static let altarSuccess = Color(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0)
    static let altarError = Color(red: 180.0/255.0, green: 40.0/255.0, blue: 40.0/255.0)

    // Legacy compatibility - map gold to red/orange
    static let altarSoftGold = Color.altarOrange
    static let altarGoldBase = Color.altarOrange
    static let altarGoldHighlight = Color.altarYellow
    static let altarGoldShadow = Color.altarRed
    static let altarGold = Color.altarOrange

    // Utility colors
    static let altarWarmWhite = Color(red: 250.0/255.0, green: 248.0/255.0, blue: 242.0/255.0)
    static let altarDeepBlue = Color(red: 28.0/255.0, green: 40.0/255.0, blue: 51.0/255.0)
    static let altarSoftGray = Color(red: 108.0/255.0, green: 117.0/255.0, blue: 125.0/255.0)
    static let altarAccentGlow = Color.altarRed.opacity(0.25)
    static let altarCardHighlight = Color.white.opacity(0.12)
    static let altarGradientStart = Color.altarRed
    static let altarGradientEnd = Color.altarOrange
    static let altarGlow = Color.altarOrange.opacity(0.4)
    static let altarBoldGlow = Color.altarRed.opacity(0.35)

    // Semantic colors
    static let altarPrimary = Color.primary
    static let altarSecondary = Color.secondary
    #if canImport(UIKit)
    static let altarTertiary = Color(UIColor.tertiaryLabel)
    #elseif canImport(AppKit)
    static let altarTertiary = Color(NSColor.tertiaryLabelColor)
    #else
    static let altarTertiary = Color.gray
    #endif

    // Card styling - simple white opacity overlays
    static let altarCard = Color.white.opacity(0.06)
    static let altarCardBorder = Color.white.opacity(0.08)
}

// MARK: - Gradients & Textures
extension LinearGradient {
    // Fire gradient for buttons and accents
    static let altarFireGradient = LinearGradient(
        colors: [.altarRed, .altarOrange, .altarYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Legacy compatibility - map gold to fire
    static let altarMetallicGold = LinearGradient(
        colors: [.altarRed, .altarOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let altarDeepNight = LinearGradient(
        colors: [.altarBlack, .altarBlack],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension RadialGradient {
    // Simple black background
    static let altarNightVignette = RadialGradient(
        gradient: Gradient(colors: [Color.altarDarkGray.opacity(0.1), Color.altarBlack]),
        center: .center,
        startRadius: 50,
        endRadius: 400
    )
}

// MARK: - Materials and Card Styles (Original Simple Style)
extension View {
    func altarCardStyle() -> some View {
        self
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.altarCard))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.altarCardBorder, lineWidth: 1)
            )
    }

    func altarGlassCardStyle() -> some View {
        self
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.altarCard))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.altarCardBorder, lineWidth: 1)
            )
    }

    func altarElevatedCardStyle() -> some View {
        self
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.08)))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.altarCardBorder, lineWidth: 1)
            )
    }

    // Fire glow effect
    func softGlow(color: Color = .altarRed, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
}

// MARK: - Typography Styles
// MARK: - Typography (Sacred Serif)
extension View {
    func altarHeadlineStyle() -> some View {
        self
            .font(.custom("Baskerville-Bold", size: 34))
            .foregroundStyle(LinearGradient.altarMetallicGold)
            .shadow(color: .altarGoldBase.opacity(0.3), radius: 10, x: 0, y: 0)
    }

    func altarBodyStyle() -> some View {
        self
            .font(.body) // Keep system font for readability
            .foregroundStyle(Color.white.opacity(0.85))
    }
    
    func altarSerifBody() -> some View {
        self
            .font(.custom("Baskerville", size: 18))
            .foregroundStyle(Color.white.opacity(0.9))
    }

    func altarCaptionStyle() -> some View {
        self
            .font(.custom("Baskerville-Italic", size: 14))
            .foregroundStyle(Color.white.opacity(0.5))
    }

    func altarTitleStyle() -> some View {
        self
            .font(.custom("Baskerville-SemiBold", size: 28))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }

    func altarSubtitleStyle() -> some View {
        self
            .font(.custom("Baskerville", size: 20))
            .foregroundStyle(Color.white.opacity(0.7))
            .multilineTextAlignment(.center)
    }

    func altarQuoteStyle() -> some View {
        self
            .font(.custom("Baskerville-Italic", size: 18))
            .foregroundStyle(Color.altarGoldBase)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

// MARK: - Button Styles
struct AltarPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.altarDeepBlue)
                    .shadow(color: Color.altarDeepBlue.opacity(0.2), radius: 8, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.shared.buttonTap()
                }
            }
    }
}

struct AltarGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.quaternary, lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.shared.selectionChanged()
                }
            }
    }
}

// MARK: - Animation Presets (Bold & Expressive)
struct AltarAnimations {
    // Base animations
    static let gentle = Animation.easeInOut(duration: 0.25)
    static let calm = Animation.easeOut(duration: 0.2)
    static let subtle = Animation.easeInOut(duration: 0.15)

    // Bold spring animations
    static let cardPress = Animation.spring(response: 0.25, dampingFraction: 0.6)
    static let pageTransition = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let slideIn = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let scaleUp = Animation.spring(response: 0.3, dampingFraction: 0.5)
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.65)

    // Expressive repeating animations
    static let glowPulse = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    static let softGlow = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)
    static let breathe = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)

    // Stagger delays for list animations
    static func staggered(index: Int, baseDelay: Double = 0.05) -> Animation {
        Animation.spring(response: 0.4, dampingFraction: 0.75).delay(Double(index) * baseDelay)
    }
}

// MARK: - Spacing & Layout Constants
struct AltarSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

// MARK: - Modifiers
extension View {
    func sacredGlow(color: Color = .altarRed, radius: CGFloat = 15) -> some View {
        self.shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)
    }

    func fireGlow(radius: CGFloat = 20) -> some View {
        self
            .shadow(color: Color.altarRed.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: Color.altarOrange.opacity(0.4), radius: radius * 1.5, x: 0, y: 0)
    }

    func metallicBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.altarCardBorder, lineWidth: 1)
        )
    }

    func altarBackground() -> some View {
        self.background(AltarBackgroundView())
    }
}

// MARK: - Global Components
struct AltarBackgroundView: View {
    var body: some View {
        Color.altarBlack.ignoresSafeArea()
    }
}

// MARK: - Fire Glow Styles
extension View {
    func boldGlow(color: Color = .altarRed, radius: CGFloat = 30) -> some View {
        self
            .shadow(color: color.opacity(0.35), radius: radius, x: 0, y: 0)
            .shadow(color: Color.altarOrange.opacity(0.15), radius: radius * 2, x: 0, y: 0)
    }

    func altarBoldCardStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.altarCardBorder, lineWidth: 1)
                    )
            )
    }
}

struct AltarBoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.altarRed, Color.altarOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.altarRed.opacity(0.4), radius: 12, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(AltarAnimations.bouncy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.shared.trigger(.medium)
                }
            }
    }
}

struct AltarSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.altarRed)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.altarRed, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AltarAnimations.cardPress, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.shared.buttonTap()
                }
            }
    }
}

struct AltarIconButtonStyle: ButtonStyle {
    var size: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundStyle(Color.altarRed)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                Circle()
                    .stroke(Color.altarRed.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(AltarAnimations.bouncy, value: configuration.isPressed)
    }
}

