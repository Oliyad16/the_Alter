import Foundation

struct Alarm: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var hour: Int
    var minute: Int
    var isEnabled: Bool = true
    // Weekdays as 1...7 (Sun=1 per Calendar), empty means every day
    var repeatWeekdays: [Int] = []
    // Allow snooze action from notification
    var allowSnooze: Bool = true
}

struct Reminder: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var notes: String? = nil
    var date: Date
    var isEnabled: Bool = true
}
