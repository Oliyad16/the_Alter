import Foundation

struct BibleProgress: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var book: String
    var chapter: Int
    var completedAt: Date

    init(id: UUID = UUID(),
         userId: UUID,
         book: String,
         chapter: Int,
         completedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.book = book
        self.chapter = chapter
        self.completedAt = completedAt
    }
}
