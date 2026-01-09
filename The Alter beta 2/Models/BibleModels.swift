import Foundation

// MARK: - API.Bible Response Models

struct BibleVersion: Codable, Identifiable {
    let id: String
    let name: String
    let language: BibleLanguage?
    let abbreviation: String?

    struct BibleLanguage: Codable {
        let id: String
        let name: String
    }
}

struct BibleBook: Codable, Identifiable {
    let id: String
    let name: String
    let abbreviation: String?
    let chapters: [BibleChapter]?
}

struct BibleChapter: Codable, Identifiable {
    let id: String
    let number: String
    let reference: String
}

struct BibleChapterContent: Codable {
    let id: String
    let number: String
    let content: String
    let reference: String
    let verseCount: Int?
}

struct BibleVerse: Codable, Identifiable {
    let id: String
    let reference: String
    let content: String
    let verseId: String?
}

// MARK: - API Response Wrappers

struct BibleAPIResponse<T: Codable>: Codable {
    let data: T
}

struct BibleBooksResponse: Codable {
    let data: [BibleBook]
}

struct BibleChaptersResponse: Codable {
    let data: [BibleChapter]
}
