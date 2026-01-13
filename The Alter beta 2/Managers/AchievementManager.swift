//
//  AchievementManager.swift
//  The Alter beta 2
//
//  Business logic for checking and unlocking achievements
//

import Foundation
import SwiftUI

@MainActor
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()

    // All available achievements (from definitions)
    let allAchievements: [Achievement] = AchievementDefinitions.all

    private init() {}

    // MARK: - Achievement Checking

    /// Check all achievements after a user action and return newly unlocked ones
    func checkAchievements(dataStore: AppDataStore) -> [Achievement] {
        var unlocked: [Achievement] = []

        for achievement in allAchievements {
            // Skip already unlocked achievements
            if dataStore.achievementProgress.isUnlocked(achievement.id) {
                continue
            }

            // Get current progress value
            let currentValue = getCurrentValue(for: achievement, dataStore: dataStore)

            // Update progress tracking
            dataStore.achievementProgress.updateProgress(
                achievementId: achievement.id,
                newProgress: currentValue
            )

            // Check if unlocked
            if currentValue >= achievement.requiredValue {
                dataStore.achievementProgress.unlock(achievementId: achievement.id)
                unlocked.append(achievement)
            }
        }

        return unlocked
    }

    // MARK: - Progress Calculation

    /// Calculate current progress value for a specific achievement
    private func getCurrentValue(for achievement: Achievement, dataStore: AppDataStore) -> Int {
        switch achievement.id {
        // MARK: Reading Achievements

        case "first_chapter":
            return dataStore.bibleProgress.isEmpty ? 0 : 1

        case "chapters_10", "chapters_50", "chapters_100", "chapters_500":
            return dataStore.bibleProgress.count

        case "reading_streak_7", "reading_streak_30", "reading_streak_100":
            return dataStore.streakData.readingStreak

        case "morning_reader_7":
            // Calculate consecutive days with reading before 7am
            // Note: Would need timestamp tracking in BibleProgress for full implementation
            // For now, return 0 as placeholder
            return 0

        // MARK: Prayer Achievements

        case "first_prayer":
            let completedSessions = dataStore.prayerSessions.filter { $0.endTime != nil }
            return completedSessions.isEmpty ? 0 : 1

        case "prayer_60min":
            let hasHourSession = dataStore.prayerSessions.contains { session in
                session.durationMinutes >= 60
            }
            return hasHourSession ? 1 : 0

        case "sessions_25", "sessions_100":
            let completedSessions = dataStore.prayerSessions.filter { $0.endTime != nil }
            return completedSessions.count

        case "prayer_streak_7", "prayer_streak_30", "prayer_streak_100":
            return dataStore.streakData.prayerStreak

        case "first_testimony":
            let answeredPrayers = dataStore.prayerItems.filter { $0.answered }
            return answeredPrayers.isEmpty ? 0 : 1

        // MARK: Answered Prayer Achievements

        case "answered_10", "answered_50", "answered_100":
            let answeredPrayers = dataStore.prayerItems.filter { $0.answered }
            return answeredPrayers.count

        // MARK: Combined & Special Achievements

        case "double_streak_7", "double_streak_30":
            // Both streaks must be at the required level
            return min(dataStore.streakData.prayerStreak, dataStore.streakData.readingStreak)

        case "identity_warrior":
            let identityClass = dataStore.commitmentProfile?.identityClass
            let isWarriorOrHigher = (identityClass == .warriorOfGod || identityClass == .generalOfGod)
            return isWarriorOrHigher ? 1 : 0

        case "identity_general":
            let identityClass = dataStore.commitmentProfile?.identityClass
            return identityClass == .generalOfGod ? 1 : 0

        default:
            return 0
        }
    }

    // MARK: - Helper Methods

    /// Get all locked achievements
    func getLockedAchievements(dataStore: AppDataStore) -> [Achievement] {
        return allAchievements.filter { achievement in
            !dataStore.achievementProgress.isUnlocked(achievement.id)
        }
    }

    /// Get all unlocked achievements
    func getUnlockedAchievements(dataStore: AppDataStore) -> [Achievement] {
        return allAchievements.filter { achievement in
            dataStore.achievementProgress.isUnlocked(achievement.id)
        }
    }

    /// Get achievements by category
    func getAchievements(byCategory category: AchievementCategory, dataStore: AppDataStore) -> [Achievement] {
        return allAchievements.filter { $0.category == category }
    }

    /// Get unlock percentage (0-100)
    func getUnlockPercentage(dataStore: AppDataStore) -> Double {
        let totalCount = Double(allAchievements.count)
        let unlockedCount = Double(getUnlockedAchievements(dataStore: dataStore).count)
        return totalCount > 0 ? (unlockedCount / totalCount) * 100.0 : 0.0
    }

    /// Get progress for a specific achievement (0.0 to 1.0)
    func getProgress(for achievementId: String, dataStore: AppDataStore) -> Double {
        guard let achievement = AchievementDefinitions.getAchievement(byId: achievementId) else {
            return 0.0
        }

        let currentProgress = dataStore.achievementProgress.getProgress(achievementId)
        return Double(currentProgress) / Double(achievement.requiredValue)
    }
}
