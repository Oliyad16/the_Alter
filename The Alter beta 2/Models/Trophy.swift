import SwiftUI

// MARK: - Trophy Tier
enum TrophyTier: String, CaseIterable, Codable {
    case bronze = "bronze"
    case silver = "silver"
    case gold = "gold"
    case platinum = "platinum"
    case diamond = "diamond"

    var displayName: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .platinum: return "Platinum"
        case .diamond: return "Diamond"
        }
    }

    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color.altarYellow
        case .platinum: return Color(red: 0.9, green: 0.9, blue: 0.95)
        case .diamond: return Color.cyan
        }
    }

    var icon: String {
        switch self {
        case .bronze: return "medal"
        case .silver: return "medal.fill"
        case .gold: return "trophy"
        case .platinum: return "trophy.fill"
        case .diamond: return "crown.fill"
        }
    }

    var minimumMinutes: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 60
        case .gold: return 300
        case .platinum: return 1000
        case .diamond: return 3000
        }
    }

    static func from(totalMinutes: Int) -> TrophyTier {
        if totalMinutes >= 3000 { return .diamond }
        if totalMinutes >= 1000 { return .platinum }
        if totalMinutes >= 300 { return .gold }
        if totalMinutes >= 60 { return .silver }
        return .bronze
    }

    var nextTier: TrophyTier? {
        switch self {
        case .bronze: return .silver
        case .silver: return .gold
        case .gold: return .platinum
        case .platinum: return .diamond
        case .diamond: return nil
        }
    }
}

// MARK: - Trophy
struct Trophy: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let requirement: String
    var unlockedAt: Date?

    var isUnlocked: Bool { unlockedAt != nil }

    init(id: UUID = UUID(), name: String, description: String, icon: String, requirement: String, unlockedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.requirement = requirement
        self.unlockedAt = unlockedAt
    }
}

// MARK: - Default Trophies
extension Trophy {
    static let allTrophies: [Trophy] = [
        // Prayer time trophies
        Trophy(name: "First Prayer", description: "Complete your first prayer session", icon: "flame", requirement: "first_prayer"),
        Trophy(name: "Prayer Warrior", description: "Pray for 10 minutes total", icon: "flame.fill", requirement: "10_minutes"),
        Trophy(name: "Faithful Servant", description: "Pray for 60 minutes total", icon: "hands.sparkles", requirement: "60_minutes"),
        Trophy(name: "Burning Heart", description: "Pray for 5 hours total", icon: "heart.fill", requirement: "300_minutes"),
        Trophy(name: "Altar Keeper", description: "Pray for 16+ hours total", icon: "flame.circle.fill", requirement: "1000_minutes"),
        Trophy(name: "Sacred Fire", description: "Pray for 50+ hours total", icon: "crown.fill", requirement: "3000_minutes"),

        // Streak trophies
        Trophy(name: "Getting Started", description: "Pray 2 days in a row", icon: "2.circle.fill", requirement: "streak_2"),
        Trophy(name: "Building Momentum", description: "Pray 7 days in a row", icon: "7.circle.fill", requirement: "streak_7"),
        Trophy(name: "Consistent", description: "Pray 14 days in a row", icon: "14.circle.fill", requirement: "streak_14"),
        Trophy(name: "Devoted", description: "Pray 30 days in a row", icon: "30.circle.fill", requirement: "streak_30"),
        Trophy(name: "Unshakeable", description: "Pray 100 days in a row", icon: "100.circle.fill", requirement: "streak_100"),

        // Session trophies
        Trophy(name: "Early Bird", description: "Pray before 6 AM", icon: "sunrise.fill", requirement: "early_bird"),
        Trophy(name: "Night Watch", description: "Pray after 10 PM", icon: "moon.stars.fill", requirement: "night_watch"),
        Trophy(name: "Long Session", description: "Pray for 30+ minutes in one session", icon: "timer", requirement: "long_session"),
        Trophy(name: "Marathon Prayer", description: "Pray for 60+ minutes in one session", icon: "figure.run", requirement: "marathon_prayer"),
    ]
}
