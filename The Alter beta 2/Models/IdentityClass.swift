import Foundation

enum IdentityClass: String, Codable, CaseIterable {
    case childOfGod = "Child of God"
    case sonOfGod = "Son of God"
    case warriorOfGod = "Warrior of God"
    case generalOfGod = "General of God"

    var description: String {
        switch self {
        case .childOfGod:
            return "1× Bible read / 25 min prayer"
        case .sonOfGod:
            return "2× Bible reads / 45 min prayer"
        case .warriorOfGod:
            return "3× Bible reads / 1 hour prayer"
        case .generalOfGod:
            return "4× Bible reads / 2+ hours prayer"
        }
    }

    var bibleReadsMin: Int {
        switch self {
        case .childOfGod: return 1
        case .sonOfGod: return 2
        case .warriorOfGod: return 3
        case .generalOfGod: return 4
        }
    }

    var prayerMinutesMin: Int {
        switch self {
        case .childOfGod: return 25
        case .sonOfGod: return 45
        case .warriorOfGod: return 60
        case .generalOfGod: return 75
        }
    }

    static func from(bibleReads: Int, prayerMinutes: Int) -> IdentityClass {
        // Both criteria must be met for higher identity classes
        if bibleReads >= 4 && prayerMinutes >= 120 {
            return .generalOfGod
        } else if bibleReads >= 3 && prayerMinutes >= 60 {
            return .warriorOfGod
        } else if bibleReads >= 2 && prayerMinutes >= 45 {
            return .sonOfGod
        } else {
            return .childOfGod
        }
    }
}
