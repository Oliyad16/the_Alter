import SwiftUI

struct FlameDetailsSheet: View {
    let flameLevel: FlameLevel
    let intensity: Double
    let colorTheme: FlameColorTheme

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Flame visualization
                    VStack(spacing: 16) {
                        FlameView(intensity: intensity, interactionEnabled: false, colorTheme: colorTheme)
                            .frame(height: 200)

                        VStack(spacing: 8) {
                            Text(flameLevel.displayName)
                                .font(.title.weight(.bold))
                                .foregroundStyle(colorTheme.glowColor)

                            Text(flameLevel.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    // Progress to next level
                    if flameLevel != .sacredFire {
                        nextLevelProgress
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.largeTitle)
                                .foregroundStyle(colorTheme.glowColor)
                            Text("Maximum Level Reached!")
                                .font(.headline)
                                .foregroundStyle(colorTheme.glowColor)
                            Text("Your altar burns with the sacred fire.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // Flame level breakdown
                    flameLevelBreakdown

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(Color.altarBlack.ignoresSafeArea())
            .navigationTitle("Your Flame")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline.weight(.medium))
                    .foregroundColor(colorTheme.glowColor)
                }
            }
        }
    }

    @ViewBuilder
    private var nextLevelProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            let nextLevel = FlameLevel(rawValue: flameLevel.rawValue + 1) ?? .sacredFire

            HStack {
                Text("Progress to \(nextLevel.displayName)")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(progressToNextLevel * 100))%")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(colorTheme.glowColor)
            }

            ProgressView(value: progressToNextLevel)
                .progressViewStyle(LinearProgressViewStyle(tint: colorTheme.glowColor))
                .scaleEffect(x: 1, y: 2)

            Text("Keep praying consistently to reach the next level!")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var flameLevelBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Flame Levels")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ForEach(FlameLevel.allCases, id: \.rawValue) { level in
                    HStack(spacing: 12) {
                        // Level indicator
                        Circle()
                            .fill(colorTheme.glowColor.opacity(level == flameLevel ? 1.0 : 0.3))
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(colorTheme.glowColor, lineWidth: level == flameLevel ? 2 : 1)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(level.displayName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(level == flameLevel ? colorTheme.glowColor : .primary)

                            Text(level.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if level == flameLevel {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(colorTheme.glowColor)
                                .font(.title3)
                        } else if level.rawValue < flameLevel.rawValue {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.tertiary)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var progressToNextLevel: Double {
        guard flameLevel != .sacredFire else { return 1.0 }

        let currentRange = flameLevel.intensityRange
        let progress = (intensity - currentRange.lowerBound) / (currentRange.upperBound - currentRange.lowerBound)
        return min(1.0, max(0.0, progress))
    }
}

#Preview {
    FlameDetailsSheet(flameLevel: .torch, intensity: 0.55, colorTheme: .classic)
}
