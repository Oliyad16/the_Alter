import Foundation

struct BibleCalculator {
    static let totalChapters = 1189
    static let avgChapterMinutes = 5

    struct CalculationResult {
        let bibleReads: Int
        let daysRemaining: Int
        let chaptersPerDay: Double
        let minutesPerDay: Double
        let displayRange: String

        init(bibleReads: Int, endDate: Date, startDate: Date = Date()) {
            self.bibleReads = bibleReads
            self.daysRemaining = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0

            if daysRemaining > 0 {
                self.chaptersPerDay = Double(BibleCalculator.totalChapters * bibleReads) / Double(daysRemaining)
                self.minutesPerDay = chaptersPerDay * Double(BibleCalculator.avgChapterMinutes)

                // Display as rounded ranges, never exact numbers
                let minMinutes = Int(minutesPerDay * 0.9)
                let maxMinutes = Int(minutesPerDay * 1.1)
                self.displayRange = "\(minMinutes)-\(maxMinutes) minutes per day"
            } else {
                self.chaptersPerDay = 0
                self.minutesPerDay = 0
                self.displayRange = "Please select a future end date"
            }
        }

        var chaptersDisplayRange: String {
            let min = Int(chaptersPerDay * 0.9)
            let max = Int(chaptersPerDay * 1.1)
            return "\(min)-\(max) chapters per day"
        }
    }

    static func calculate(bibleReads: Int, endDate: Date) -> CalculationResult {
        return CalculationResult(bibleReads: bibleReads, endDate: endDate)
    }

    static func defaultYearEndDate() -> Date {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        return calendar.date(from: DateComponents(year: year, month: 12, day: 31)) ?? now
    }
}
