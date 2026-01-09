import Foundation

struct CommitmentProfile: Codable {
    var userId: UUID
    var bibleReadsTarget: Int // 1, 2, 3, or custom
    var prayerMinutesTarget: Int // 25, 45, 60, 75, or custom
    var identityClass: IdentityClass
    var startDate: Date
    var endDate: Date

    init(userId: UUID,
         bibleReadsTarget: Int,
         prayerMinutesTarget: Int,
         startDate: Date = Date(),
         endDate: Date) {
        self.userId = userId
        self.bibleReadsTarget = bibleReadsTarget
        self.prayerMinutesTarget = prayerMinutesTarget
        self.identityClass = IdentityClass.from(bibleReads: bibleReadsTarget, prayerMinutes: prayerMinutesTarget)
        self.startDate = startDate
        self.endDate = endDate
    }

    mutating func updateCommitment(bibleReads: Int, prayerMinutes: Int) {
        self.bibleReadsTarget = bibleReads
        self.prayerMinutesTarget = prayerMinutes
        self.identityClass = IdentityClass.from(bibleReads: bibleReads, prayerMinutes: prayerMinutes)
    }
}
