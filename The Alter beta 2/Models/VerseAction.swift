import Foundation
import SwiftUI

enum VerseActionType: String, Codable {
    case highlight
    case prayLater
    case note
}

enum HighlightColor: String, Codable, CaseIterable, Identifiable {
    case yellow = "yellow"
    case orange = "orange"
    case red = "red"
    case pink = "pink"
    case purple = "purple"
    case blue = "blue"
    case green = "green"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .yellow: return .yellow
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        case .purple: return .purple
        case .blue: return .blue
        case .green: return .green
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

enum HighlightCategory: String, Codable, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case actionItems = "Action Items"
    case questions = "Questions"
    case insights = "Insights"
    case prayer = "Prayer Verses"
    case memorization = "Memorization"
    case shareLater = "Share Later"
    case general = "General"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .favorites: return "star.fill"
        case .actionItems: return "checkmark.circle.fill"
        case .questions: return "questionmark.circle.fill"
        case .insights: return "lightbulb.fill"
        case .prayer: return "flame.fill"
        case .memorization: return "brain.head.profile"
        case .shareLater: return "square.and.arrow.up.fill"
        case .general: return "tag.fill"
        }
    }

    var defaultColor: HighlightColor {
        switch self {
        case .favorites: return .yellow
        case .actionItems: return .green
        case .questions: return .blue
        case .insights: return .orange
        case .prayer: return .pink
        case .memorization: return .purple
        case .shareLater: return .red
        case .general: return .yellow
        }
    }

    var iconColor: Color {
        switch self {
        case .favorites: return .yellow
        case .actionItems: return .green
        case .questions: return .blue
        case .insights: return .orange
        case .prayer: return .pink
        case .memorization: return .purple
        case .shareLater: return .red
        case .general: return .gray
        }
    }

    var description: String {
        switch self {
        case .favorites: return "Verses you love and cherish"
        case .actionItems: return "Verses to apply in your life"
        case .questions: return "Verses to study and understand better"
        case .insights: return "Aha moments and revelations"
        case .prayer: return "Verses to pray and meditate on"
        case .memorization: return "Verses you want to memorize"
        case .shareLater: return "Verses to share with others"
        case .general: return "General highlights"
        }
    }
}

struct VerseAction: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var verseId: String // Format: "book.chapter.verse" (e.g., "GEN.1.1")
    var action: VerseActionType
    var content: String? // Store verse text for offline access
    var noteText: String? // For note action type
    var highlightColor: HighlightColor? // For highlight action type
    var highlightCategory: HighlightCategory? // For highlight categorization (optional for backward compatibility)
    var createdAt: Date
    var prayedAt: Date? // When user actually prayed for this verse

    init(id: UUID = UUID(),
         userId: UUID,
         verseId: String,
         action: VerseActionType,
         content: String? = nil,
         noteText: String? = nil,
         highlightColor: HighlightColor? = nil,
         highlightCategory: HighlightCategory? = nil,
         createdAt: Date = Date(),
         prayedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.verseId = verseId
        self.action = action
        self.content = content
        self.noteText = noteText
        self.highlightColor = highlightColor
        self.highlightCategory = highlightCategory
        self.createdAt = createdAt
        self.prayedAt = prayedAt
    }
}
