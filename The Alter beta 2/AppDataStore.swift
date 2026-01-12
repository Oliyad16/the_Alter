import Foundation
import Combine

// MARK: - Streak Data Structure
struct StreakData: Codable {
    var prayerStreak: Int = 0
    var longestPrayerStreak: Int = 0
    var lastPrayerDate: Date? = nil

    var readingStreak: Int = 0
    var longestReadingStreak: Int = 0
    var lastReadingDate: Date? = nil
}

// MARK: - Bible Progress Stats
struct BibleProgressStats {
    let totalChaptersGoal: Int
    let chaptersCompleted: Int
    let percentComplete: Double
    let isOnTrack: Bool
    let chaptersAheadOrBehind: Int
    let updatedChaptersPerDay: Double
    let daysRemaining: Int
    let statusMessage: String
    let weeklyChaptersRead: Int
}

final class AppDataStore: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User? { didSet { persistUser() } }
    @Published var commitmentProfile: CommitmentProfile? { didSet { persistCommitmentProfile() } }
    @Published var bibleProgress: [BibleProgress] = [] { didSet { persistBibleProgress() } }
    @Published var verseActions: [VerseAction] = [] { didSet { persistVerseActions() } }
    @Published var prayerSessions: [PrayerSession] = [] { didSet { persistPrayerSessions() } }
    @Published var prayerItems: [PrayerItem] = [] { didSet { persistPrayerItems() } }
    @Published var dailyMetrics: [DailyMetrics] = [] { didSet { persistDailyMetrics() } }
    @Published var alarms: [Alarm] = [] { didSet { persistAlarms() } }
    @Published var reminders: [Reminder] = [] { didSet { persistReminders() } }

    // MARK: - Streak Data
    @Published var streakData: StreakData = StreakData() { didSet { persistStreakData() } }

    // MARK: - Flame Color Theme
    @Published var flameColorTheme: FlameColorTheme = .classic {
        didSet {
            UserDefaults.standard.set(flameColorTheme.rawValue, forKey: flameColorThemeKey)
        }
    }
    private let flameColorThemeKey = "settings.flameColorTheme"

    // MARK: - Reading Settings
    @Published var bibleFontSize: CGFloat = 17 {
        didSet {
            UserDefaults.standard.set(bibleFontSize, forKey: bibleFontSizeKey)
        }
    }
    private let bibleFontSizeKey = "settings.bibleFontSize"

    @Published var bibleFontFamily: String = "Georgia" {
        didSet {
            UserDefaults.standard.set(bibleFontFamily, forKey: bibleFontFamilyKey)
        }
    }
    private let bibleFontFamilyKey = "settings.bibleFontFamily"

    @Published var bibleLineSpacing: CGFloat = 8 {
        didSet {
            UserDefaults.standard.set(bibleLineSpacing, forKey: bibleLineSpacingKey)
        }
    }
    private let bibleLineSpacingKey = "settings.bibleLineSpacing"

    @Published var bibleContinuousMode: Bool = false {
        didSet {
            UserDefaults.standard.set(bibleContinuousMode, forKey: bibleContinuousModeKey)
        }
    }
    private let bibleContinuousModeKey = "bible.continuousScrollMode"

    // MARK: - Keys
    private let userKey = "user.v2"
    private let commitmentKey = "commitment.v2"
    private let bibleProgressKey = "bibleProgress.v2"
    private let verseActionsKey = "verseActions.v2"
    private let prayerSessionsKey = "prayerSessions.v2"
    private let prayerItemsKey = "prayerItems.v2"
    private let dailyMetricsKey = "dailyMetrics.v2"
    private let alarmsKey = "alarms.v2"
    private let remindersKey = "reminders.v2"
    private let streakDataKey = "streakData.v2"

    init() {
        loadAll()
    }

    // MARK: - Load Data
    private func loadAll() {
        currentUser = loadData(key: userKey, type: User.self)
        commitmentProfile = loadData(key: commitmentKey, type: CommitmentProfile.self)
        bibleProgress = loadData(key: bibleProgressKey, type: [BibleProgress].self) ?? []
        verseActions = loadData(key: verseActionsKey, type: [VerseAction].self) ?? []
        prayerSessions = loadData(key: prayerSessionsKey, type: [PrayerSession].self) ?? []
        prayerItems = loadData(key: prayerItemsKey, type: [PrayerItem].self) ?? []
        dailyMetrics = loadData(key: dailyMetricsKey, type: [DailyMetrics].self) ?? []
        alarms = loadData(key: alarmsKey, type: [Alarm].self) ?? []
        reminders = loadData(key: remindersKey, type: [Reminder].self) ?? []
        streakData = loadData(key: streakDataKey, type: StreakData.self) ?? StreakData()

        // Load flame color theme
        if let storedTheme = UserDefaults.standard.string(forKey: flameColorThemeKey),
           let theme = FlameColorTheme(rawValue: storedTheme) {
            flameColorTheme = theme
        }

        // Load reading settings
        let savedFontSize = UserDefaults.standard.object(forKey: bibleFontSizeKey) as? CGFloat
        if let savedFontSize = savedFontSize {
            bibleFontSize = savedFontSize
        }
        if let savedFontFamily = UserDefaults.standard.string(forKey: bibleFontFamilyKey) {
            bibleFontFamily = savedFontFamily
        }
        let savedLineSpacing = UserDefaults.standard.object(forKey: bibleLineSpacingKey) as? CGFloat
        if let savedLineSpacing = savedLineSpacing {
            bibleLineSpacing = savedLineSpacing
        }
        bibleContinuousMode = UserDefaults.standard.bool(forKey: bibleContinuousModeKey)
    }

    private func loadData<T: Codable>(key: String, type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Persist Data
    private func persistUser() {
        persistData(currentUser, key: userKey)
    }

    private func persistCommitmentProfile() {
        persistData(commitmentProfile, key: commitmentKey)
    }

    private func persistBibleProgress() {
        persistData(bibleProgress, key: bibleProgressKey)
    }

    private func persistVerseActions() {
        persistData(verseActions, key: verseActionsKey)
    }

    private func persistPrayerSessions() {
        persistData(prayerSessions, key: prayerSessionsKey)
    }

    private func persistPrayerItems() {
        persistData(prayerItems, key: prayerItemsKey)
    }

    private func persistDailyMetrics() {
        persistData(dailyMetrics, key: dailyMetricsKey)
    }

    private func persistAlarms() {
        persistData(alarms, key: alarmsKey)
    }

    private func persistReminders() {
        persistData(reminders, key: remindersKey)
    }

    private func persistStreakData() {
        persistData(streakData, key: streakDataKey)
    }

    private func persistData<T: Codable>(_ data: T, key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // MARK: - User Management
    func createUser() -> User {
        let user = User()
        currentUser = user
        return user
    }

    func completeOnboarding(commitment: CommitmentProfile) {
        commitmentProfile = commitment
        currentUser?.onboardingCompleted = true
    }

    // MARK: - Bible Progress
    func markChapterComplete(book: String, chapter: Int) {
        guard let userId = currentUser?.id else { return }
        let progress = BibleProgress(userId: userId, book: book, chapter: chapter)
        bibleProgress.append(progress)

        // Update daily metrics
        updateTodaysMetrics(readingMinutes: 5, chaptersRead: 1)

        // Update streaks
        updateStreaks()
    }

    // MARK: - Verse Actions
    func addVerseAction(verseId: String, action: VerseActionType, content: String?, highlightColor: HighlightColor? = nil) {
        guard let userId = currentUser?.id else { return }
        let verseAction = VerseAction(userId: userId, verseId: verseId, action: action, content: content, highlightColor: highlightColor)
        verseActions.append(verseAction)
    }

    func removeVerseAction(verseId: String, action: VerseActionType) {
        verseActions.removeAll { $0.verseId == verseId && $0.action == action }
    }

    func getPrayLaterVerses() -> [VerseAction] {
        return verseActions.filter { $0.action == .prayLater && $0.prayedAt == nil }
    }

    // MARK: - Notes
    func addNote(verseId: String, content: String, noteText: String) {
        guard let userId = currentUser?.id else { return }
        let note = VerseAction(userId: userId, verseId: verseId, action: .note, content: content, noteText: noteText)
        verseActions.append(note)
    }

    func updateNote(noteId: UUID, noteText: String) {
        guard let index = verseActions.firstIndex(where: { $0.id == noteId }) else { return }
        verseActions[index].noteText = noteText
    }

    func deleteNote(noteId: UUID) {
        verseActions.removeAll { $0.id == noteId }
    }

    func getNotes() -> [VerseAction] {
        return verseActions.filter { $0.action == .note }
    }

    func getNotesForVerse(verseId: String) -> [VerseAction] {
        return verseActions.filter { $0.verseId == verseId && $0.action == .note }
    }

    // MARK: - Highlights
    func getHighlightForVerse(verseId: String) -> VerseAction? {
        return verseActions.first { $0.verseId == verseId && $0.action == .highlight }
    }

    func updateHighlightColor(verseId: String, color: HighlightColor) {
        guard let index = verseActions.firstIndex(where: { $0.verseId == verseId && $0.action == .highlight }) else { return }
        verseActions[index].highlightColor = color
    }

    // MARK: - Prayer Sessions
    func startPrayerSession(silentMode: Bool = false) -> PrayerSession? {
        guard let userId = currentUser?.id else {
            // Return nil instead of crashing - the view should handle this gracefully
            return nil
        }
        let session = PrayerSession(userId: userId, silentMode: silentMode)
        prayerSessions.append(session)
        return session
    }

    func endPrayerSession(_ sessionId: UUID) {
        guard let index = prayerSessions.firstIndex(where: { $0.id == sessionId }) else { return }
        prayerSessions[index].endTime = Date()

        // Update daily metrics
        let duration = prayerSessions[index].durationMinutes
        updateTodaysMetrics(prayerMinutes: duration)

        // Update streaks
        updateStreaks()
    }

    // MARK: - Prayer Items
    func addPrayerItem(type: PrayerItemType, content: String, verseId: String? = nil) {
        guard let userId = currentUser?.id else { return }
        let item = PrayerItem(userId: userId, type: type, content: content, verseId: verseId)
        prayerItems.append(item)
    }

    func addPrayerPointFromVerse(verseId: String, content: String) {
        guard let userId = currentUser?.id else { return }
        let item = PrayerItem(
            userId: userId,
            type: .verseReflection,
            content: content,
            verseId: verseId
        )
        prayerItems.append(item)
        Task { @MainActor in
            HapticManager.shared.trigger(.success)
        }
    }

    func markPrayerAnswered(_ itemId: UUID) {
        guard let index = prayerItems.firstIndex(where: { $0.id == itemId }) else { return }
        prayerItems[index].answered = true
        prayerItems[index].answeredAt = Date()
    }

    func getRememberedPrayers() -> [PrayerItem] {
        return prayerItems.filter { $0.answered }
    }

    // MARK: - Daily Metrics
    private func updateTodaysMetrics(prayerMinutes: Int = 0, readingMinutes: Int = 0, chaptersRead: Int = 0) {
        guard let userId = currentUser?.id else { return }

        let today = Calendar.current.startOfDay(for: Date())

        if let index = dailyMetrics.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            dailyMetrics[index].prayerMinutes += prayerMinutes
            dailyMetrics[index].readingMinutes += readingMinutes
            dailyMetrics[index].chaptersRead += chaptersRead
        } else {
            let metrics = DailyMetrics(
                userId: userId,
                date: today,
                prayerMinutes: prayerMinutes,
                readingMinutes: readingMinutes,
                chaptersRead: chaptersRead
            )
            dailyMetrics.append(metrics)
        }
    }

    func getMetrics(for date: Date) -> DailyMetrics? {
        return dailyMetrics.first {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    // MARK: - Bible Progress Calculations
    var bibleProgressStats: BibleProgressStats {
        guard let commitment = commitmentProfile else {
            return BibleProgressStats(
                totalChaptersGoal: 0,
                chaptersCompleted: 0,
                percentComplete: 0,
                isOnTrack: true,
                chaptersAheadOrBehind: 0,
                updatedChaptersPerDay: 0,
                daysRemaining: 0,
                statusMessage: "Set your Bible reading goal to track progress",
                weeklyChaptersRead: 0
            )
        }

        let totalChaptersGoal = BibleCalculator.totalChapters * commitment.bibleReadsTarget
        let chaptersCompleted = bibleProgress.count
        let percentComplete = totalChaptersGoal > 0 ? Double(chaptersCompleted) / Double(totalChaptersGoal) * 100 : 0

        let calendar = Calendar.current
        let now = Date()
        let daysElapsed = max(1, calendar.dateComponents([.day], from: commitment.startDate, to: now).day ?? 1)
        let daysRemaining = max(0, calendar.dateComponents([.day], from: now, to: commitment.endDate).day ?? 0)

        let totalDays = max(1, calendar.dateComponents([.day], from: commitment.startDate, to: commitment.endDate).day ?? 1)
        let expectedChapters = Double(totalChaptersGoal) * (Double(daysElapsed) / Double(totalDays))
        let chaptersAheadOrBehind = chaptersCompleted - Int(expectedChapters.rounded())
        let isOnTrack = chaptersAheadOrBehind >= -3

        let chaptersRemaining = max(0, totalChaptersGoal - chaptersCompleted)
        let updatedChaptersPerDay = daysRemaining > 0 ? Double(chaptersRemaining) / Double(daysRemaining) : 0

        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        let weeklyChaptersRead = bibleProgress.filter { $0.completedAt >= weekStart }.count

        let statusMessage: String
        if chaptersCompleted >= totalChaptersGoal {
            statusMessage = "Goal completed! Praise God!"
        } else if chaptersAheadOrBehind > 5 {
            statusMessage = "Ahead of schedule! Keep going!"
        } else if chaptersAheadOrBehind >= -3 {
            statusMessage = "Right on track!"
        } else if daysRemaining > 0 {
            statusMessage = "You can still finish! Read \(Int(updatedChaptersPerDay.rounded(.up))) chapters/day"
        } else {
            statusMessage = "Behind schedule, but keep reading!"
        }

        return BibleProgressStats(
            totalChaptersGoal: totalChaptersGoal,
            chaptersCompleted: chaptersCompleted,
            percentComplete: percentComplete,
            isOnTrack: isOnTrack,
            chaptersAheadOrBehind: chaptersAheadOrBehind,
            updatedChaptersPerDay: updatedChaptersPerDay,
            daysRemaining: daysRemaining,
            statusMessage: statusMessage,
            weeklyChaptersRead: weeklyChaptersRead
        )
    }

    // MARK: - Streak Calculation
    func updateStreaks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        updatePrayerStreak(today: today, calendar: calendar)
        updateReadingStreak(today: today, calendar: calendar)
    }

    private func updatePrayerStreak(today: Date, calendar: Calendar) {
        let prayerDates = Set(prayerSessions
            .filter { $0.endTime != nil }
            .map { calendar.startOfDay(for: $0.startTime) })

        let newStreak = calculateStreak(dates: prayerDates, today: today, calendar: calendar)
        streakData.prayerStreak = newStreak
        if newStreak > streakData.longestPrayerStreak {
            streakData.longestPrayerStreak = newStreak
        }
        if prayerDates.contains(today) {
            streakData.lastPrayerDate = today
        }
    }

    private func updateReadingStreak(today: Date, calendar: Calendar) {
        let readingDates = Set(dailyMetrics
            .filter { $0.chaptersRead > 0 }
            .map { calendar.startOfDay(for: $0.date) })

        let newStreak = calculateStreak(dates: readingDates, today: today, calendar: calendar)
        streakData.readingStreak = newStreak
        if newStreak > streakData.longestReadingStreak {
            streakData.longestReadingStreak = newStreak
        }
        if readingDates.contains(today) {
            streakData.lastReadingDate = today
        }
    }

    private func calculateStreak(dates: Set<Date>, today: Date, calendar: Calendar) -> Int {
        if dates.isEmpty { return 0 }
        var streak = 0
        var currentDay = today

        while dates.contains(currentDay) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else { break }
            currentDay = previousDay
        }

        if !dates.contains(today) {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               !dates.contains(yesterday) {
                return 0
            }
        }

        return streak
    }

    // MARK: - Alarms & Reminders
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }
    }

    func updateAlarm(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        NotificationManager.shared.cancelAll(withPrefix: alarm.id.uuidString)
        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }
    }

    func removeAlarm(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        NotificationManager.shared.cancelAll(withPrefix: alarm.id.uuidString)
    }

    private func scheduleAlarm(_ alarm: Alarm) {
        if alarm.repeatWeekdays.isEmpty {
            NotificationManager.shared.scheduleDailyAlarm(
                id: alarm.id.uuidString,
                title: alarm.title,
                hour: alarm.hour,
                minute: alarm.minute
            )
        } else {
            NotificationManager.shared.scheduleWeeklyAlarmSeries(
                baseId: alarm.id.uuidString,
                title: alarm.title,
                hour: alarm.hour,
                minute: alarm.minute,
                weekdays: alarm.repeatWeekdays
            )
        }
    }

    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        if reminder.isEnabled {
            NotificationManager.shared.scheduleOneOffReminder(
                id: reminder.id.uuidString,
                title: reminder.title,
                body: reminder.notes,
                date: reminder.date
            )
        }
    }

    func updateReminder(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index] = reminder
        NotificationManager.shared.cancelNotification(id: reminder.id.uuidString)
        if reminder.isEnabled {
            NotificationManager.shared.scheduleOneOffReminder(
                id: reminder.id.uuidString,
                title: reminder.title,
                body: reminder.notes,
                date: reminder.date
            )
        }
    }

    func removeReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        NotificationManager.shared.cancelNotification(id: reminder.id.uuidString)
    }
}
