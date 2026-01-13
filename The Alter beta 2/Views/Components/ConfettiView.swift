//
//  ConfettiView.swift
//  The Alter beta 2
//
//  Confetti particle animation for celebrations
//

import SwiftUI

// MARK: - Confetti Particle Model

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var rotation: Double = 0
    var opacity: Double = 1.0
}

// MARK: - Confetti Piece View

struct ConfettiPiece: View {
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .cornerRadius(2)
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    let colors: [Color]
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(color: particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Particle Generation

    private func generateParticles(in size: CGSize) {
        for i in 0..<50 {
            let particle = ConfettiParticle(
                color: colors.randomElement() ?? .white,
                x: CGFloat.random(in: 0...size.width),
                y: -50,
                size: CGFloat.random(in: 8...16)
            )
            particles.append(particle)

            animateParticle(index: i, screenHeight: size.height)
        }
    }

    // MARK: - Particle Animation

    private func animateParticle(index: Int, screenHeight: CGFloat) {
        let delay = Double.random(in: 0...0.5)
        let duration = Double.random(in: 2.5...4.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.linear(duration: duration)) {
                particles[index].y = screenHeight + 50
                particles[index].rotation = Double.random(in: 360...720)
                particles[index].x += CGFloat.random(in: -100...100)
            }

            // Fade out at the end
            let fadeDelay = delay + duration - 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) {
                withAnimation(.easeOut(duration: 0.5)) {
                    particles[index].opacity = 0
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConfettiView(colors: [
            .altarYellow,
            .altarOrange,
            .altarRed,
            .white
        ])
    }
}
