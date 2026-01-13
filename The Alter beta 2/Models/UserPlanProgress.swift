//
//  UserPlanProgress.swift
//  The Alter beta 2
//
//  Tracks user's progress through an active reading plan
//

import Foundation

struct UserPlanProgress: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var planId: UUID
    var planType: ReadingPlanType
    var currentDay: Int
    var startDate: Date
    var pausedDate: Date?
    var isPaused: Bool
    var completedDays: Set<Int>      // Track which days are done
    var completedReadings: [String]  // Track individual readings (book.chapter)
    var lastReadDate: Date?

    init(userId: UUID, planId: UUID, planType: ReadingPlanType, startDate: Date = Date()) {
        self.id = UUID()
        self.userId = userId
        self.planId = planId
        self.planType = planType
        self.currentDay = 1
        self.startDate = startDate
        self.isPaused = false
        self.completedDays = []
        self.completedReadings = []
        self.lastReadDate = nil
    }

    mutating func markDayComplete(day: Int) {
        completedDays.insert(day)
        lastReadDate = Date()
    }

    mutating func markReadingComplete(book: String, chapter: Int) {
        let key = "\(book).\(chapter)"
        if !completedReadings.contains(key) {
            completedReadings.append(key)
        }
    }

    mutating func pause() {
        isPaused = true
        pausedDate = Date()
    }

    mutating func resume() {
        isPaused = false
        pausedDate = nil
    }

    var progressPercentage: Double {
        guard !completedDays.isEmpty else { return 0 }
        return Double(completedDays.count) / Double(currentDay) * 100
    }

    func isReadingComplete(book: String, chapter: Int) -> Bool {
        let key = "\(book).\(chapter)"
        return completedReadings.contains(key)
    }
}
