import SwiftUI

struct SacredFlameIcon: View {
    var size: CGFloat = 64
    var colorTheme: FlameColorTheme = .classic
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        colorTheme.glowColor.opacity(0.2 - Double(index) * 0.05),
                        lineWidth: 1
                    )
                    .frame(width: size + CGFloat(index * 8), height: size + CGFloat(index * 8))
                    .scaleEffect(scale)
            }
            
            // Sparkles around the flame
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.15))
                    .foregroundColor(colorTheme.glowColor.opacity(sparkleOpacity))
                    .offset(
                        x: cos(Double(index) * .pi / 4) * Double(size * 0.6),
                        y: sin(Double(index) * .pi / 4) * Double(size * 0.6)
                    )
                    .rotationEffect(.degrees(rotation))
            }
            
            // Main flame with gradient
            ZStack {
                // Back glow
                Image(systemName: "flame.fill")
                    .font(.system(size: size))
                    .foregroundColor(colorTheme.glowColor.opacity(0.3))
                    .blur(radius: 4)
                    .offset(y: -2)
                
                // Main flame
                Image(systemName: "flame.fill")
                    .font(.system(size: size))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colorTheme.primaryColors,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                
                // Inner highlight
                Image(systemName: "flame.fill")
                    .font(.system(size: size * 0.7))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colorTheme.coreColors,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .blendMode(.overlay)
            }
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation * 0.1))
            
            // Top sparkle accent
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.2))
                .foregroundColor(colorTheme.glowColor)
                .offset(y: -size * 0.5)
                .opacity(sparkleOpacity * 2)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Gentle rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Breathing scale
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            scale = 1.05
        }
        
        // Sparkle pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            sparkleOpacity = 0.8
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        SacredFlameIcon(size: 64, colorTheme: .classic)
        SacredFlameIcon(size: 64, colorTheme: .blue)
        SacredFlameIcon(size: 64, colorTheme: .purple)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.altarBlack)
}

