//
//  AchievementsView.swift
//  The Alter beta 2
//
//  Achievement gallery with filters and progress tracking
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedCategory: AchievementCategory?
    @State private var selectedAchievement: Achievement?

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]

    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return AchievementDefinitions.all.filter { $0.category == category }
        }
        return AchievementDefinitions.all
    }

    var unlockedCount: Int {
        return AchievementManager.shared.getUnlockedAchievements(dataStore: dataStore).count
    }

    var totalCount: Int {
        return AchievementDefinitions.all.count
    }

    var unlockPercentage: Double {
        return AchievementManager.shared.getUnlockPercentage(dataStore: dataStore)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.altarBlack.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category picker
                    categoryPicker
                        .padding(.vertical)

                    // Stats header
                    statsHeader
                        .padding(.horizontal)
                        .padding(.bottom)

                    // Achievement grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementBadge(
                                    achievement: achievement,
                                    userAchievement: dataStore.achievementProgress.userAchievements[achievement.id],
                                    dataStore: dataStore
                                )
                                .onTapGesture {
                                    selectedAchievement = achievement
                                    HapticManager.shared.trigger(.light)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailView(
                    achievement: achievement,
                    userAchievement: dataStore.achievementProgress.userAchievements[achievement.id],
                    dataStore: dataStore
                )
            }
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" button
                Button(action: {
                    selectedCategory = nil
                    HapticManager.shared.trigger(.soft)
                }) {
                    Text("All")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedCategory == nil ? .black : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(selectedCategory == nil ? Color.altarYellow : Color.white.opacity(0.1))
                        .cornerRadius(20)
                }

                ForEach(AchievementCategory.allCases) { category in
                    Button(action: {
                        selectedCategory = category
                        HapticManager.shared.trigger(.soft)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            Text(category.rawValue)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedCategory == category ? .black : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(selectedCategory == category ? category.color : Color.white.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(unlockedCount)/\(totalCount)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                Text("Achievements Unlocked")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: unlockPercentage / 100)
                    .stroke(Color.altarYellow, lineWidth: 8)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(unlockPercentage))%")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
    }
}

// MARK: - Achievement Badge

struct AchievementBadge: View {
    let achievement: Achievement
    let userAchievement: UserAchievement?
    let dataStore: AppDataStore

    private var isUnlocked: Bool {
        userAchievement?.isUnlocked ?? false
    }

    private var progress: Double {
        guard let userAchievement = userAchievement else { return 0 }
        return Double(userAchievement.progress) / Double(achievement.requiredValue)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Progress ring (if not unlocked and has progress)
                if !isUnlocked && progress > 0 {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(achievement.tierColor, lineWidth: 3)
                        .rotationEffect(.degrees(-90))
                }

                // Background circle
                Circle()
                    .fill(isUnlocked ? achievement.tierColor.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)

                // Icon
                Image(systemName: achievement.iconName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(isUnlocked ? achievement.tierColor : .white.opacity(0.3))

                // Lock overlay for locked achievements
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.4))
                        .offset(x: 25, y: 25)
                }
            }
            .frame(width: 90, height: 90)

            Text(achievement.title)
                .font(.caption.weight(.medium))
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
        }
        .frame(width: 100)
    }
}

// MARK: - Achievement Detail View

struct AchievementDetailView: View {
    @Environment(\.dismiss) var dismiss
    let achievement: Achievement
    let userAchievement: UserAchievement?
    let dataStore: AppDataStore

    private var isUnlocked: Bool {
        userAchievement?.isUnlocked ?? false
    }

    private var progress: Int {
        userAchievement?.progress ?? 0
    }

    private var progressPercentage: Double {
        Double(progress) / Double(achievement.requiredValue) * 100
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.altarBlack.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Achievement icon
                    ZStack {
                        Circle()
                            .fill(achievement.tierColor.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .shadow(color: achievement.tierColor.opacity(isUnlocked ? 0.6 : 0.2), radius: 30)

                        Image(systemName: achievement.iconName)
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(isUnlocked ? achievement.tierColor : .white.opacity(0.3))

                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.4))
                                .offset(x: 40, y: 40)
                        }
                    }
                    .padding(.top, 24)

                    // Title and category
                    VStack(spacing: 8) {
                        Text(achievement.title)
                            .font(.title.weight(.bold))
                            .foregroundColor(.white)

                        Text(achievement.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)

                        // Tier badge
                        Text(achievement.tier.displayName.uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(achievement.tierColor)
                            .cornerRadius(20)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)

                    // Progress section
                    VStack(spacing: 12) {
                        if isUnlocked {
                            // Unlocked info
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.altarSuccess)

                                Text("Unlocked!")
                                    .font(.headline)
                                    .foregroundColor(.altarSuccess)

                                if let unlockedDate = userAchievement?.unlockedAt {
                                    Text("on \(unlockedDate, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Text(achievement.unlockMessage)
                                    .font(.subheadline.italic())
                                    .foregroundColor(.altarSoftGold)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                            }
                            .padding()
                            .background(Color.altarSuccess.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            // Progress info
                            VStack(spacing: 12) {
                                Text("Progress")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .textCase(.uppercase)

                                Text("\(progress) / \(achievement.requiredValue)")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.white)

                                ProgressView(value: Double(progress), total: Double(achievement.requiredValue))
                                    .tint(achievement.tierColor)
                                    .frame(height: 8)

                                Text("\(Int(progressPercentage))% Complete")
                                    .font(.caption)
                                    .foregroundColor(achievement.tierColor)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.altarOrange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle(achievement.category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AchievementsView()
            .environmentObject(AppDataStore())
    }
}
