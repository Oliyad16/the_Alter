import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var email: String?
    let createdAt: Date
    var timezone: String
    var onboardingCompleted: Bool

    init(id: UUID = UUID(),
         email: String? = nil,
         createdAt: Date = Date(),
         timezone: String = TimeZone.current.identifier,
         onboardingCompleted: Bool = false) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
        self.timezone = timezone
        self.onboardingCompleted = onboardingCompleted
    }
}
