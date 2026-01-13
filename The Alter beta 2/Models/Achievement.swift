//
//  Achievement.swift
//  The Alter beta 2
//
//  Achievement system for tracking user milestones and progress
//

import Foundation
import SwiftUI

// MARK: - Achievement Category

enum AchievementCategory: String, Codable, CaseIterable, Identifiable {
    case reading = "Reading"
    case prayer = "Prayer"
    case combined = "Combined"
    case special = "Special"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .reading: return "book.fill"
        case .prayer: return "flame.fill"
        case .combined: return "sparkles"
        case .special: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .reading: return .altarOrange
        case .prayer: return .altarRed
        case .combined: return .altarYellow
        case .special: return .purple
        }
    }
}

// MARK: - Achievement Tier

enum AchievementTier: String, Codable {
    case bronze
    case silver
    case gold
    case platinum

    var color: Color {
        switch self {
        case .bronze: return .altarOrange
        case .silver: return Color.white.opacity(0.9)
        case .gold: return .altarYellow
        case .platinum: return .purple
        }
    }

    var displayName: String {
        return rawValue.capitalized
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable, Hashable {
    let id: String // e.g., "first_chapter", "prayer_streak_7"
    let title: String
    let description: String
    let category: AchievementCategory
    let tier: AchievementTier
    let iconName: String // SF Symbol
    let requiredValue: Int
    let unlockMessage: String // Celebration text shown on unlock

    init(id: String,
         title: String,
         description: String,
         category: AchievementCategory,
         tier: AchievementTier,
         iconName: String,
         requiredValue: Int,
         unlockMessage: String) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.tier = tier
        self.iconName = iconName
        self.requiredValue = requiredValue
        self.unlockMessage = unlockMessage
    }

    // Computed property for color based on tier
    var tierColor: Color {
        return tier.color
    }
}

// MARK: - User Achievement

struct UserAchievement: Codable {
    let achievementId: String
    var isUnlocked: Bool
    var unlockedAt: Date?
    var progress: Int // Current progress toward achievement
    var notificationShown: Bool // Track if we've shown celebration

    init(achievementId: String,
         isUnlocked: Bool = false,
         unlockedAt: Date? = nil,
         progress: Int = 0,
         notificationShown: Bool = false) {
        self.achievementId = achievementId
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.progress = progress
        self.notificationShown = notificationShown
    }
}

// MARK: - Achievement Progress

struct AchievementProgress: Codable {
    var userAchievements: [String: UserAchievement] = [:] // achievementId -> UserAchievement

    mutating func updateProgress(achievementId: String, newProgress: Int) {
        if userAchievements[achievementId] == nil {
            userAchievements[achievementId] = UserAchievement(achievementId: achievementId)
        }
        userAchievements[achievementId]?.progress = newProgress
    }

    mutating func unlock(achievementId: String) {
        if userAchievements[achievementId] == nil {
            userAchievements[achievementId] = UserAchievement(achievementId: achievementId)
        }
        userAchievements[achievementId]?.isUnlocked = true
        userAchievements[achievementId]?.unlockedAt = Date()
    }

    func isUnlocked(_ achievementId: String) -> Bool {
        return userAchievements[achievementId]?.isUnlocked ?? false
    }

    func getProgress(_ achievementId: String) -> Int {
        return userAchievements[achievementId]?.progress ?? 0
    }

    func getProgressPercentage(_ achievementId: String, requiredValue: Int) -> Double {
        let current = Double(getProgress(achievementId))
        let required = Double(requiredValue)
        return min(current / required, 1.0)
    }
}
