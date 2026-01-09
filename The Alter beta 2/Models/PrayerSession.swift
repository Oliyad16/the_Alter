import Foundation

struct PrayerSession: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var startTime: Date
    var endTime: Date?
    var silentMode: Bool
    var durationMinutes: Int {
        guard let endTime = endTime else { return 0 }
        return Int((endTime.timeIntervalSince(startTime)) / 60)
    }

    init(id: UUID = UUID(),
         userId: UUID,
         startTime: Date = Date(),
         endTime: Date? = nil,
         silentMode: Bool = false) {
        self.id = id
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.silentMode = silentMode
    }
}
