//
//  AchievementUnlockView.swift
//  The Alter beta 2
//
//  Full-screen celebration modal for achievement unlocks
//

import SwiftUI

struct AchievementUnlockView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool

    @State private var showContent = false
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -10

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti particles
            if showConfetti {
                ConfettiView(colors: [
                    achievement.tierColor,
                    .altarOrange,
                    .altarYellow,
                    .white
                ])
            }

            // Main card
            VStack(spacing: 24) {
                // Achievement icon with glow
                ZStack {
                    Circle()
                        .fill(achievement.tierColor.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .shadow(color: achievement.tierColor.opacity(0.6), radius: 30)

                    Image(systemName: achievement.iconName)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(achievement.tierColor)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))

                VStack(spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .tracking(2)

                    Text(achievement.title)
                        .font(.title.weight(.bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(achievement.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Unlock message
                    Text(achievement.unlockMessage)
                        .font(.subheadline.italic())
                        .foregroundColor(.altarSoftGold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 4)

                    // Tier badge
                    Text(achievement.tier.displayName.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(achievement.tierColor)
                        .cornerRadius(20)
                        .padding(.top, 8)
                }
                .opacity(showContent ? 1 : 0)

                Button(action: dismiss) {
                    Text("Continue")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [achievement.tierColor, achievement.tierColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .opacity(showContent ? 1 : 0)
                .padding(.horizontal)
            }
            .frame(maxWidth: 350)
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.altarDarkGray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(achievement.tierColor.opacity(0.5), lineWidth: 2)
                    )
            )
        }
        .onAppear {
            performUnlockAnimation()
        }
    }

    // MARK: - Animation

    private func performUnlockAnimation() {
        // Trigger achievement haptic
        HapticManager.shared.trigger(.achievement)

        // Scale and rotate in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            rotation = 0
        }

        // Show content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                showContent = true
            }
        }

        // Show confetti and celebration haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showConfetti = true
            HapticManager.shared.trigger(.celebration)
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isPresented = true

    return ZStack {
        Color.altarBlack.ignoresSafeArea()

        if isPresented {
            AchievementUnlockView(
                achievement: Achievement(
                    id: "first_chapter",
                    title: "First Steps",
                    description: "Read your first Bible chapter",
                    category: .reading,
                    tier: .bronze,
                    iconName: "book.fill",
                    requiredValue: 1,
                    unlockMessage: "You've taken your first step into God's Word!"
                ),
                isPresented: $isPresented
            )
        }
    }
}
