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

struct VerseAction: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var verseId: String // Format: "book.chapter.verse" (e.g., "GEN.1.1")
    var action: VerseActionType
    var content: String? // Store verse text for offline access
    var noteText: String? // For note action type
    var highlightColor: HighlightColor? // For highlight action type
    var createdAt: Date
    var prayedAt: Date? // When user actually prayed for this verse

    init(id: UUID = UUID(),
         userId: UUID,
         verseId: String,
         action: VerseActionType,
         content: String? = nil,
         noteText: String? = nil,
         highlightColor: HighlightColor? = nil,
         createdAt: Date = Date(),
         prayedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.verseId = verseId
        self.action = action
        self.content = content
        self.noteText = noteText
        self.highlightColor = highlightColor
        self.createdAt = createdAt
        self.prayedAt = prayedAt
    }
}
