import SwiftUI
import Combine

class TrophyManager: ObservableObject {
    static let shared = TrophyManager()

    @Published var trophies: [Trophy] = []
    @Published var recentlyUnlocked: [Trophy] = []
    @Published private(set) var totalMinutes: Int = 0
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0

    private let userDefaultsKey = "trophy.manager.data"

    private init() {
        loadData()
        initializeTrophiesIfNeeded()
    }

    // MARK: - Flame Intensity
    func getFlameIntensity() -> Double {
        // Based on weekly activity and streak
        let weeklyMinutes = getWeeklyMinutes()
        let normalizedWeekly = min(1.0, Double(weeklyMinutes) / 120.0)
        let normalizedStreak = min(1.0, Double(currentStreak) / 7.0)
        return max(0.1, (normalizedWeekly * 0.6 + normalizedStreak * 0.4))
    }

    func getCurrentTrophyTier() -> TrophyTier {
        TrophyTier.from(totalMinutes: totalMinutes)
    }

    func getNextTrophy() -> Trophy? {
        trophies.first { !$0.isUnlocked }
    }

    // MARK: - Prayer Session Tracking
    func trackPrayerSession(durationMinutes: Int, startTime: Date) {
        totalMinutes += durationMinutes

        // Update streak
        updateStreak(for: startTime)

        // Check time-based trophies
        checkTimeTrophies()

        // Check streak trophies
        checkStreakTrophies()

        // Check session-specific trophies
        checkSessionTrophies(durationMinutes: durationMinutes, startTime: startTime)

        saveData()
    }

    private func updateStreak(for sessionDate: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessionDay = calendar.startOfDay(for: sessionDate)

        let lastPrayerDateKey = "trophy.lastPrayerDate"
        let storedTimestamp = UserDefaults.standard.double(forKey: lastPrayerDateKey)

        if storedTimestamp > 0 {
            let lastPrayerDate = calendar.startOfDay(for: Date(timeIntervalSince1970: storedTimestamp))
            let daysDiff = calendar.dateComponents([.day], from: lastPrayerDate, to: sessionDay).day ?? 0

            if daysDiff == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysDiff > 1 {
                // Streak broken
                currentStreak = 1
            }
            // daysDiff == 0 means same day, don't change streak
        } else {
            // First prayer ever
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        UserDefaults.standard.set(sessionDay.timeIntervalSince1970, forKey: lastPrayerDateKey)
    }

    // MARK: - Trophy Checking
    private func checkTimeTrophies() {
        checkAndUnlock("first_prayer") { true }
        checkAndUnlock("10_minutes") { totalMinutes >= 10 }
        checkAndUnlock("60_minutes") { totalMinutes >= 60 }
        checkAndUnlock("300_minutes") { totalMinutes >= 300 }
        checkAndUnlock("1000_minutes") { totalMinutes >= 1000 }
        checkAndUnlock("3000_minutes") { totalMinutes >= 3000 }
    }

    private func checkStreakTrophies() {
        checkAndUnlock("streak_2") { currentStreak >= 2 }
        checkAndUnlock("streak_7") { currentStreak >= 7 }
        checkAndUnlock("streak_14") { currentStreak >= 14 }
        checkAndUnlock("streak_30") { currentStreak >= 30 }
        checkAndUnlock("streak_100") { currentStreak >= 100 }
    }

    private func checkSessionTrophies(durationMinutes: Int, startTime: Date) {
        let hour = Calendar.current.component(.hour, from: startTime)

        checkAndUnlock("early_bird") { hour < 6 }
        checkAndUnlock("night_watch") { hour >= 22 }
        checkAndUnlock("long_session") { durationMinutes >= 30 }
        checkAndUnlock("marathon_prayer") { durationMinutes >= 60 }
    }

    private func checkAndUnlock(_ requirement: String, condition: () -> Bool) {
        guard let index = trophies.firstIndex(where: { $0.requirement == requirement && !$0.isUnlocked }) else { return }

        if condition() {
            trophies[index].unlockedAt = Date()
            recentlyUnlocked.append(trophies[index])

            // Notify for celebration
            NotificationCenter.default.post(name: .trophyUnlocked, object: trophies[index])

            // Trigger haptic on main actor
            Task { @MainActor in
                HapticManager.shared.trigger(.heavy)
            }
        }
    }

    func clearRecentlyUnlocked() {
        recentlyUnlocked.removeAll()
    }

    // MARK: - Weekly Minutes
    private func getWeeklyMinutes() -> Int {
        // This should ideally pull from AppDataStore, but for now return based on recent activity
        let weeklyKey = "trophy.weeklyMinutes"
        return UserDefaults.standard.integer(forKey: weeklyKey)
    }

    func updateWeeklyMinutes(_ minutes: Int) {
        UserDefaults.standard.set(minutes, forKey: "trophy.weeklyMinutes")
    }

    // MARK: - Persistence
    private func initializeTrophiesIfNeeded() {
        if trophies.isEmpty {
            trophies = Trophy.allTrophies
            saveData()
        }
    }

    private func loadData() {
        totalMinutes = UserDefaults.standard.integer(forKey: "trophy.totalMinutes")
        currentStreak = UserDefaults.standard.integer(forKey: "trophy.currentStreak")
        longestStreak = UserDefaults.standard.integer(forKey: "trophy.longestStreak")

        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Trophy].self, from: data) {
            trophies = decoded
        }
    }

    private func saveData() {
        UserDefaults.standard.set(totalMinutes, forKey: "trophy.totalMinutes")
        UserDefaults.standard.set(currentStreak, forKey: "trophy.currentStreak")
        UserDefaults.standard.set(longestStreak, forKey: "trophy.longestStreak")

        if let encoded = try? JSONEncoder().encode(trophies) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    static let trophyUnlocked = Notification.Name("trophyUnlocked")
}
