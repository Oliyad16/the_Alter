import SwiftUI

struct TrophyCelebrationView: View {
    let trophy: Trophy
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -180
    @State private var showConfetti = false
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            // Confetti effect
            if showConfetti {
                confettiView
            }
            
            VStack(spacing: AltarSpacing.extraLarge) {
                Spacer()
                
                // Trophy icon with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    trophyTier.color.opacity(glowIntensity),
                                    trophyTier.color.opacity(0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 30)
                    
                    // Trophy
                    Image(systemName: trophy.icon.isEmpty ? trophyTier.icon : trophy.icon)
                        .font(.system(size: 100, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    trophyTier.color,
                                    trophyTier.color.opacity(0.7),
                                    trophyTier.color
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                        .shadow(color: trophyTier.color.opacity(0.6), radius: 30, x: 0, y: 0)
                }
                
                VStack(spacing: AltarSpacing.medium) {
                    Text("Trophy Unlocked!")
                        .font(.custom("Baskerville-Bold", size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [trophyTier.color, trophyTier.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .opacity(scale >= 1.0 ? 1 : 0)
                    
                    Text(trophy.name)
                        .font(.custom("Baskerville-Bold", size: 28))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(scale >= 1.0 ? 1 : 0)
                    
                    Text(trophy.description)
                        .font(.custom("Baskerville", size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(scale >= 1.0 ? 1 : 0)
                    
                    // Tier badge
                    HStack(spacing: 8) {
                        Image(systemName: trophyTier.icon)
                            .font(.caption)
                        Text(trophyTier.displayName)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(trophyTier.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(trophyTier.color.opacity(0.15))
                    .cornerRadius(20)
                    .opacity(scale >= 1.0 ? 1 : 0)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    HapticManager.shared.trigger(.medium)
                    TrophyManager.shared.clearRecentlyUnlocked()
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.custom("Baskerville-Bold", size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [trophyTier.color, trophyTier.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: trophyTier.color.opacity(0.4), radius: 15, x: 0, y: 5)
                }
                .padding(.horizontal, AltarSpacing.large)
                .padding(.bottom, AltarSpacing.extraLarge)
                .opacity(scale >= 1.0 ? 1 : 0)
            }
        }
        .onAppear {
            startCelebration()
        }
    }
    
    private var trophyTier: TrophyTier {
        // Determine tier based on trophy requirement or use gold as default
        if trophy.requirement.contains("3000") {
            return .diamond
        } else if trophy.requirement.contains("1000") {
            return .platinum
        } else if trophy.requirement.contains("300") {
            return .gold
        } else if trophy.requirement.contains("60") || trophy.requirement.contains("streak_30") {
            return .silver
        } else {
            return .bronze
        }
    }
    
    private func startCelebration() {
        // Haptic feedback
        HapticManager.shared.trigger(.heavy)
        
        // Animate trophy appearance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            rotation = 0
        }
        
        // Show confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfetti = true
        }
        
        // Pulse glow
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 0.7
        }
    }
    
    @ViewBuilder
    private var confettiView: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(trophyTier.color.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .opacity(showConfetti ? 0 : 1)
                    .animation(
                        .easeOut(duration: Double.random(in: 1.5...3.0))
                        .delay(Double(index) * 0.05),
                        value: showConfetti
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    TrophyCelebrationView(
        trophy: Trophy(
            name: "Prayer Warrior",
            description: "Pray for 10 minutes total",
            icon: "flame.fill",
            requirement: "10_minutes",
            unlockedAt: Date()
        )
    )
}

