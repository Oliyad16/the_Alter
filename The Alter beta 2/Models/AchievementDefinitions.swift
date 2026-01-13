//
//  AchievementDefinitions.swift
//  The Alter beta 2
//
//  Static repository of all available achievements
//

import Foundation

struct AchievementDefinitions {
    static let all: [Achievement] = [
        // MARK: - Reading Achievements (9)

        Achievement(
            id: "first_chapter",
            title: "First Steps",
            description: "Read your first Bible chapter",
            category: .reading,
            tier: .bronze,
            iconName: "book.fill",
            requiredValue: 1,
            unlockMessage: "You've taken your first step into God's Word!"
        ),

        Achievement(
            id: "chapters_10",
            title: "Chapter Marathon",
            description: "Complete 10 chapters",
            category: .reading,
            tier: .bronze,
            iconName: "books.vertical.fill",
            requiredValue: 10,
            unlockMessage: "Your dedication to Scripture is growing!"
        ),

        Achievement(
            id: "chapters_50",
            title: "Devoted Reader",
            description: "Complete 50 chapters",
            category: .reading,
            tier: .silver,
            iconName: "text.book.closed.fill",
            requiredValue: 50,
            unlockMessage: "The Word is becoming part of you!"
        ),

        Achievement(
            id: "chapters_100",
            title: "Scripture Scholar",
            description: "Complete 100 chapters",
            category: .reading,
            tier: .gold,
            iconName: "graduationcap.fill",
            requiredValue: 100,
            unlockMessage: "You're becoming a student of the Word!"
        ),

        Achievement(
            id: "chapters_500",
            title: "Biblical Mastery",
            description: "Complete 500 chapters",
            category: .reading,
            tier: .platinum,
            iconName: "crown.fill",
            requiredValue: 500,
            unlockMessage: "Your knowledge of Scripture is extraordinary!"
        ),

        Achievement(
            id: "reading_streak_7",
            title: "Week of Word",
            description: "7-day reading streak",
            category: .reading,
            tier: .bronze,
            iconName: "calendar.badge.checkmark",
            requiredValue: 7,
            unlockMessage: "A full week in the Word - amazing!"
        ),

        Achievement(
            id: "reading_streak_30",
            title: "Consistent Scholar",
            description: "30-day reading streak",
            category: .reading,
            tier: .silver,
            iconName: "calendar.badge.clock",
            requiredValue: 30,
            unlockMessage: "A month of consistent reading - you're transformed!"
        ),

        Achievement(
            id: "reading_streak_100",
            title: "Eternal Flame",
            description: "100-day reading streak",
            category: .reading,
            tier: .gold,
            iconName: "flame.circle.fill",
            requiredValue: 100,
            unlockMessage: "100 days! The Word has become your daily bread!"
        ),

        Achievement(
            id: "morning_reader_7",
            title: "Morning Light",
            description: "Read before 7am for 7 days",
            category: .special,
            tier: .silver,
            iconName: "sunrise.fill",
            requiredValue: 7,
            unlockMessage: "You're seeking God in the morning hours!"
        ),

        // MARK: - Prayer Achievements (8)

        Achievement(
            id: "first_prayer",
            title: "First Prayer",
            description: "Complete your first prayer session",
            category: .prayer,
            tier: .bronze,
            iconName: "flame.fill",
            requiredValue: 1,
            unlockMessage: "You've entered the altar of prayer!"
        ),

        Achievement(
            id: "prayer_60min",
            title: "Hour of Power",
            description: "Pray for 60 minutes straight",
            category: .prayer,
            tier: .silver,
            iconName: "clock.fill",
            requiredValue: 1,
            unlockMessage: "You devoted a full hour to God!"
        ),

        Achievement(
            id: "sessions_25",
            title: "Prayer Warrior",
            description: "Complete 25 prayer sessions",
            category: .prayer,
            tier: .bronze,
            iconName: "shield.fill",
            requiredValue: 25,
            unlockMessage: "You're becoming a warrior in prayer!"
        ),

        Achievement(
            id: "sessions_100",
            title: "Faithful Intercessor",
            description: "Complete 100 prayer sessions",
            category: .prayer,
            tier: .silver,
            iconName: "hands.sparkles.fill",
            requiredValue: 100,
            unlockMessage: "Your faithfulness in prayer is remarkable!"
        ),

        Achievement(
            id: "prayer_streak_7",
            title: "Week of Prayer",
            description: "7-day prayer streak",
            category: .prayer,
            tier: .bronze,
            iconName: "calendar.badge.checkmark",
            requiredValue: 7,
            unlockMessage: "Seven days of continuous prayer!"
        ),

        Achievement(
            id: "prayer_streak_30",
            title: "Devoted Heart",
            description: "30-day prayer streak",
            category: .prayer,
            tier: .silver,
            iconName: "heart.circle.fill",
            requiredValue: 30,
            unlockMessage: "Your heart is devoted to prayer!"
        ),

        Achievement(
            id: "prayer_streak_100",
            title: "Unceasing Prayer",
            description: "100-day prayer streak",
            category: .prayer,
            tier: .gold,
            iconName: "infinity.circle.fill",
            requiredValue: 100,
            unlockMessage: "You pray without ceasing - incredible!"
        ),

        Achievement(
            id: "first_testimony",
            title: "First Testimony",
            description: "Mark your first prayer as answered",
            category: .prayer,
            tier: .bronze,
            iconName: "checkmark.circle.fill",
            requiredValue: 1,
            unlockMessage: "God has answered! Give Him glory!"
        ),

        // MARK: - Answered Prayer Achievements (3)

        Achievement(
            id: "answered_10",
            title: "God is Faithful",
            description: "10 answered prayers",
            category: .prayer,
            tier: .silver,
            iconName: "checkmark.seal.fill",
            requiredValue: 10,
            unlockMessage: "God's faithfulness is evident in your life!"
        ),

        Achievement(
            id: "answered_50",
            title: "Witness of Miracles",
            description: "50 answered prayers",
            category: .prayer,
            tier: .gold,
            iconName: "star.circle.fill",
            requiredValue: 50,
            unlockMessage: "You've witnessed God's power repeatedly!"
        ),

        Achievement(
            id: "answered_100",
            title: "Living Testimony",
            description: "100 answered prayers",
            category: .prayer,
            tier: .platinum,
            iconName: "sparkles",
            requiredValue: 100,
            unlockMessage: "Your life is a testimony of God's faithfulness!"
        ),

        // MARK: - Combined & Special Achievements (4)

        Achievement(
            id: "double_streak_7",
            title: "Double Fire",
            description: "Both prayer and reading streaks at 7 days",
            category: .combined,
            tier: .gold,
            iconName: "flame.fill",
            requiredValue: 7,
            unlockMessage: "You're balancing Word and Prayer perfectly!"
        ),

        Achievement(
            id: "double_streak_30",
            title: "Balanced Disciple",
            description: "Both streaks at 30 days simultaneously",
            category: .combined,
            tier: .platinum,
            iconName: "scale.3d",
            requiredValue: 30,
            unlockMessage: "Perfect balance - Word and Prayer united!"
        ),

        Achievement(
            id: "identity_warrior",
            title: "Warrior Risen",
            description: "Reach Warrior of God identity or higher",
            category: .special,
            tier: .silver,
            iconName: "figure.martial.arts",
            requiredValue: 1,
            unlockMessage: "You've become a Warrior of God!"
        ),

        Achievement(
            id: "identity_general",
            title: "General's Commission",
            description: "Reach General of God identity",
            category: .special,
            tier: .platinum,
            iconName: "star.fill",
            requiredValue: 1,
            unlockMessage: "You are a General in God's army!"
        ),
    ]

    // MARK: - Helper Methods

    static func getAchievement(byId id: String) -> Achievement? {
        return all.first { $0.id == id }
    }

    static func getAchievements(byCategory category: AchievementCategory) -> [Achievement] {
        return all.filter { $0.category == category }
    }

    static func getAchievements(byTier tier: AchievementTier) -> [Achievement] {
        return all.filter { $0.tier == tier }
    }
}
