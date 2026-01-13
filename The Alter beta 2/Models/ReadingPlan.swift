//
//  ReadingPlan.swift
//  The Alter beta 2
//
//  Data models for structured Bible reading plans
//

import Foundation
import SwiftUI

// MARK: - Reading Plan Type

enum ReadingPlanType: String, Codable, CaseIterable {
    case oneYearBible = "one_year_bible"
    case chronological = "chronological"
    case newTestament90 = "nt_90_days"
    case gospels = "gospels_only"
    case psalmsProverbs = "psalms_proverbs"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .oneYearBible: return "One Year Bible"
        case .chronological: return "Chronological Bible"
        case .newTestament90: return "NT in 90 Days"
        case .gospels: return "Gospels Only"
        case .psalmsProverbs: return "Psalms & Proverbs"
        case .custom: return "Custom Plan"
        }
    }
}

// MARK: - Reading Reference

struct ReadingReference: Identifiable, Codable, Hashable {
    let id: UUID
    var book: String          // "Genesis", "Matthew", etc.
    var startChapter: Int
    var endChapter: Int?      // nil for single chapter, set for ranges
    var label: String?        // Optional display label ("Psalm 1-5")

    init(book: String, startChapter: Int, endChapter: Int? = nil, label: String? = nil) {
        self.id = UUID()
        self.book = book
        self.startChapter = startChapter
        self.endChapter = endChapter
        self.label = label
    }

    var displayText: String {
        if let label = label { return label }
        if let end = endChapter, end > startChapter {
            return "\(book) \(startChapter)-\(end)"
        }
        return "\(book) \(startChapter)"
    }

    var chapterCount: Int {
        if let end = endChapter {
            return end - startChapter + 1
        }
        return 1
    }

    // Generate chapter keys for tracking (e.g., "Genesis.1", "Genesis.2")
    var chapterKeys: [String] {
        var keys: [String] = []
        let endChap = endChapter ?? startChapter
        for chapter in startChapter...endChap {
            keys.append("\(book).\(chapter)")
        }
        return keys
    }
}

// MARK: - Reading Assignment

struct ReadingAssignment: Identifiable, Codable, Hashable {
    let id: UUID
    var dayNumber: Int
    var readings: [ReadingReference]

    init(dayNumber: Int, readings: [ReadingReference]) {
        self.id = UUID()
        self.dayNumber = dayNumber
        self.readings = readings
    }

    var totalChapters: Int {
        readings.reduce(0) { $0 + $1.chapterCount }
    }

    var displayText: String {
        readings.map { $0.displayText }.joined(separator: ", ")
    }
}

// MARK: - Reading Plan

struct ReadingPlan: Identifiable, Codable, Hashable {
    let id: UUID
    var planType: ReadingPlanType
    var name: String
    var description: String
    var icon: String           // SF Symbol name
    var totalDays: Int
    var dailyAssignments: [ReadingAssignment]
    var tags: [String]         // ["OT", "NT", "Wisdom", "Chronological"]
    var estimatedMinutesPerDay: Int

    init(planType: ReadingPlanType,
         name: String,
         description: String,
         icon: String,
         totalDays: Int,
         dailyAssignments: [ReadingAssignment],
         tags: [String] = [],
         estimatedMinutesPerDay: Int) {
        self.id = UUID()
        self.planType = planType
        self.name = name
        self.description = description
        self.icon = icon
        self.totalDays = totalDays
        self.dailyAssignments = dailyAssignments
        self.tags = tags
        self.estimatedMinutesPerDay = estimatedMinutesPerDay
    }

    func getAssignment(forDay day: Int) -> ReadingAssignment? {
        return dailyAssignments.first { $0.dayNumber == day }
    }
}
