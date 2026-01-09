import Foundation

struct DailyMetrics: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var date: Date
    var prayerMinutes: Int
    var readingMinutes: Int
    var chaptersRead: Int

    // Hidden internal weighting (not shown to user)
    var internalScore: Int {
        var score = 0
        if prayerMinutes > 0 { score += 1 }
        if readingMinutes > 0 { score += 1 }
        if prayerMinutes > 0 && readingMinutes > 0 { score += 2 }
        // verse_prayed check would need to look at VerseActions
        return score
    }

    init(id: UUID = UUID(),
         userId: UUID,
         date: Date,
         prayerMinutes: Int = 0,
         readingMinutes: Int = 0,
         chaptersRead: Int = 0) {
        self.id = id
        self.userId = userId
        self.date = date
        self.prayerMinutes = prayerMinutes
        self.readingMinutes = readingMinutes
        self.chaptersRead = chaptersRead
    }
}
