import Foundation

enum PrayerItemType: String, Codable {
    case scripture // From "Pray Later" verses
    case personal // User's own prayer points
    case verseReflection // "Prayer Point" - verses for deep meditation/reflection
}

struct PrayerItem: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var type: PrayerItemType
    var content: String
    var verseId: String? // If type is scripture
    var createdAt: Date
    var answered: Bool
    var answeredAt: Date?

    init(id: UUID = UUID(),
         userId: UUID,
         type: PrayerItemType,
         content: String,
         verseId: String? = nil,
         createdAt: Date = Date(),
         answered: Bool = false,
         answeredAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.type = type
        self.content = content
        self.verseId = verseId
        self.createdAt = createdAt
        self.answered = answered
        self.answeredAt = answeredAt
    }
}
