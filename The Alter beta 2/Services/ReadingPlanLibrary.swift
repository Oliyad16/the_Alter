//
//  ReadingPlanLibrary.swift
//  The Alter beta 2
//
//  Repository of pre-built reading plans
//

import Foundation

class ReadingPlanLibrary {
    static let shared = ReadingPlanLibrary()

    private init() {}

    func getAllPlans() -> [ReadingPlan] {
        return [
            createGospelsPlan(),
            createPsalmsProverbsPlan(),
            createNT90DaysPlan(),
            createOneYearBiblePlan(),
            createChronologicalPlan()
        ]
    }

    func getPlan(type: ReadingPlanType) -> ReadingPlan? {
        return getAllPlans().first { $0.planType == type }
    }

    // MARK: - Gospels Only (89 days) - COMPLETE

    private func createGospelsPlan() -> ReadingPlan {
        var assignments: [ReadingAssignment] = []
        var dayNum = 1

        // Matthew (28 chapters)
        for chapter in 1...28 {
            assignments.append(ReadingAssignment(
                dayNumber: dayNum,
                readings: [ReadingReference(book: "Matthew", startChapter: chapter)]
            ))
            dayNum += 1
        }

        // Mark (16 chapters)
        for chapter in 1...16 {
            assignments.append(ReadingAssignment(
                dayNumber: dayNum,
                readings: [ReadingReference(book: "Mark", startChapter: chapter)]
            ))
            dayNum += 1
        }

        // Luke (24 chapters)
        for chapter in 1...24 {
            assignments.append(ReadingAssignment(
                dayNumber: dayNum,
                readings: [ReadingReference(book: "Luke", startChapter: chapter)]
            ))
            dayNum += 1
        }

        // John (21 chapters)
        for chapter in 1...21 {
            assignments.append(ReadingAssignment(
                dayNumber: dayNum,
                readings: [ReadingReference(book: "John", startChapter: chapter)]
            ))
            dayNum += 1
        }

        return ReadingPlan(
            planType: .gospels,
            name: "Gospels Only",
            description: "Rotate through Matthew, Mark, Luke, and John to know Jesus better",
            icon: "cross.fill",
            totalDays: 89,
            dailyAssignments: assignments,
            tags: ["NT", "Gospels", "Jesus"],
            estimatedMinutesPerDay: 5
        )
    }

    // MARK: - Psalms & Proverbs (31 days) - COMPLETE

    private func createPsalmsProverbsPlan() -> ReadingPlan {
        var assignments: [ReadingAssignment] = []

        // 31-day cycle: 1 Psalm + 1 Proverb each day
        // Psalms cycle through 150 (5 per day for 30 days)
        for day in 1...31 {
            var readings: [ReadingReference] = []

            // Add 5 Psalms per day (cycling through 150)
            let psalmStart = ((day - 1) * 5) + 1
            let psalmEnd = min(psalmStart + 4, 150)
            readings.append(ReadingReference(
                book: "Psalms",
                startChapter: psalmStart,
                endChapter: psalmEnd,
                label: "Psalms \(psalmStart)-\(psalmEnd)"
            ))

            // Add 1 Proverb (cycling through 31)
            let proverbChapter = ((day - 1) % 31) + 1
            readings.append(ReadingReference(book: "Proverbs", startChapter: proverbChapter))

            assignments.append(ReadingAssignment(dayNumber: day, readings: readings))
        }

        return ReadingPlan(
            planType: .psalmsProverbs,
            name: "Psalms & Proverbs",
            description: "Daily wisdom from Psalms and Proverbs for spiritual growth",
            icon: "lightbulb.fill",
            totalDays: 31,
            dailyAssignments: assignments,
            tags: ["Wisdom", "Psalms", "Proverbs", "Short"],
            estimatedMinutesPerDay: 10
        )
    }

    // MARK: - NT in 90 Days (90 days) - STARTER

    private func createNT90DaysPlan() -> ReadingPlan {
        var assignments: [ReadingAssignment] = []

        // Simplified: ~3 chapters per day through NT
        // Full implementation would have all 260 NT chapters divided over 90 days
        let ntBooks = [
            ("Matthew", 28), ("Mark", 16), ("Luke", 24), ("John", 21),
            ("Acts", 28), ("Romans", 16), ("1 Corinthians", 16), ("2 Corinthians", 13)
            // ... more books would be added
        ]

        var dayNum = 1
        var currentBookIndex = 0
        var currentChapter = 1

        while dayNum <= 90 && currentBookIndex < ntBooks.count {
            let (book, totalChapters) = ntBooks[currentBookIndex]
            let endChapter = min(currentChapter + 2, totalChapters) // ~3 chapters per day

            assignments.append(ReadingAssignment(
                dayNumber: dayNum,
                readings: [ReadingReference(
                    book: book,
                    startChapter: currentChapter,
                    endChapter: endChapter > currentChapter ? endChapter : nil
                )]
            ))

            currentChapter = endChapter + 1
            if currentChapter > totalChapters {
                currentBookIndex += 1
                currentChapter = 1
            }
            dayNum += 1
        }

        return ReadingPlan(
            planType: .newTestament90,
            name: "NT in 90 Days",
            description: "Complete the New Testament in 3 months with focused daily reading",
            icon: "90.circle.fill",
            totalDays: 90,
            dailyAssignments: assignments,
            tags: ["NT", "Gospels", "Fast-paced"],
            estimatedMinutesPerDay: 15
        )
    }

    // MARK: - One Year Bible (365 days) - STARTER

    private func createOneYearBiblePlan() -> ReadingPlan {
        var assignments: [ReadingAssignment] = []

        // Simplified starter version - full version would have all 365 days
        // Each day: OT + NT + Psalm + Proverbs
        for day in 1...365 {
            var readings: [ReadingReference] = []

            // OT: Genesis through Malachi (roughly 3 chapters/day)
            let otChapter = ((day - 1) * 3) + 1
            if otChapter <= 929 { // Total OT chapters
                readings.append(ReadingReference(book: "Genesis", startChapter: otChapter % 50 + 1))
            }

            // NT: Matthew through Revelation (roughly 1 chapter/day)
            let ntChapter = ((day - 1) % 260) + 1
            readings.append(ReadingReference(book: "Matthew", startChapter: ntChapter % 28 + 1))

            // Psalm of the day
            let psalmNum = ((day - 1) % 150) + 1
            readings.append(ReadingReference(book: "Psalms", startChapter: psalmNum))

            // Proverb of the day
            let proverbNum = ((day - 1) % 31) + 1
            readings.append(ReadingReference(book: "Proverbs", startChapter: proverbNum))

            assignments.append(ReadingAssignment(dayNumber: day, readings: readings))
        }

        return ReadingPlan(
            planType: .oneYearBible,
            name: "One Year Bible",
            description: "Read through the entire Bible in one year with daily selections from OT, NT, Psalms, and Proverbs",
            icon: "calendar",
            totalDays: 365,
            dailyAssignments: assignments,
            tags: ["OT", "NT", "Psalms", "Proverbs", "Comprehensive"],
            estimatedMinutesPerDay: 15
        )
    }

    // MARK: - Chronological Bible (365 days) - STARTER

    private func createChronologicalPlan() -> ReadingPlan {
        var assignments: [ReadingAssignment] = []

        // Simplified starter - full version would follow historical order
        // Starting with Job (oldest book), then Genesis, etc.
        let chronologicalStart = [
            (1, "Job", 1, 3),
            (2, "Job", 4, 6),
            (3, "Job", 7, 9),
            (4, "Genesis", 1, 3),
            (5, "Genesis", 4, 6),
            // ... would continue through entire Bible in chronological order
        ]

        for (day, book, startChap, endChap) in chronologicalStart {
            assignments.append(ReadingAssignment(
                dayNumber: day,
                readings: [ReadingReference(
                    book: book,
                    startChapter: startChap,
                    endChapter: endChap
                )]
            ))
        }

        // Fill remaining days with placeholder
        for day in 6...365 {
            assignments.append(ReadingAssignment(
                dayNumber: day,
                readings: [ReadingReference(book: "Genesis", startChapter: ((day - 1) % 50) + 1)]
            ))
        }

        return ReadingPlan(
            planType: .chronological,
            name: "Chronological Bible",
            description: "Experience the Bible in the order events occurred historically",
            icon: "clock.arrow.circlepath",
            totalDays: 365,
            dailyAssignments: assignments,
            tags: ["Chronological", "Historical", "Comprehensive"],
            estimatedMinutesPerDay: 15
        )
    }
}
