import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private override init() { super.init() }

    private func defaultAlarmBody(forHour hour: Int) -> String {
        switch hour {
        case 5..<11:
            return "Good morning. It's time to pray."
        case 11..<18:
            return "It's time to pray."
        default:
            return "Good evening. It's time to pray."
        }
    }

    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        // First check current settings
        center.getNotificationSettings { [weak self] settings in
            print("[NotificationManager] Current authorization status: \(settings.authorizationStatus.rawValue)")
            print("[NotificationManager] Alert setting: \(settings.alertSetting.rawValue)")
            print("[NotificationManager] Sound setting: \(settings.soundSetting.rawValue)")
            print("[NotificationManager] Time Sensitive setting: \(settings.timeSensitiveSetting.rawValue)")
            
            if settings.authorizationStatus == .denied {
                print("[NotificationManager] ❌ Notifications are DENIED. User must enable in Settings.")
                DispatchQueue.main.async { completion?(false) }
                return
            }
            
            if settings.authorizationStatus == .authorized {
                print("[NotificationManager] ✅ Already authorized")
                DispatchQueue.main.async { completion?(true) }
                return
            }
            
            // Request authorization with comprehensive options
            self?.center.requestAuthorization(options: [
                .alert, 
                .sound, 
                .badge, 
                .timeSensitive,  // Important for breaking through Focus modes
                .criticalAlert   // Requires special entitlement but doesn't hurt to request
            ]) { granted, error in
                if let error = error {
                    print("[NotificationManager] ❌ Authorization error: \(error.localizedDescription)")
                } else {
                    print("[NotificationManager] \(granted ? "✅" : "❌") Authorization granted: \(granted)")
                }
                
                // Double-check the final settings
                self?.center.getNotificationSettings { finalSettings in
                    print("[NotificationManager] Final authorization status: \(finalSettings.authorizationStatus.rawValue)")
                    print("[NotificationManager] Final time sensitive setting: \(finalSettings.timeSensitiveSetting.rawValue)")
                    
                    DispatchQueue.main.async {
                        completion?(granted)
                    }
                }
            }
        }
    }
    
    func checkNotificationSettings(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func scheduleDailyAlarm(id: String, title: String, hour: Int, minute: Int) {
        cancelAll(withPrefix: id)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = defaultAlarmBody(forHour: hour)
        content.sound = .default
        content.categoryIdentifier = Self.prayerAlarmCategoryId
        
        // Enhanced configuration for better outside-app functionality
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive  // Break through Focus
            content.relevanceScore = 1.0  // Highest priority
        }
        content.badge = 1
        content.threadIdentifier = "prayer-alarms"  // Group alarms together
        
        // Add userInfo for debugging
        content.userInfo = [
            "alarmId": id,
            "scheduledFor": "\(hour):\(minute)",
            "type": "daily-alarm",
            "timestamp": Date().timeIntervalSince1970
        ]

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        print("[NotificationManager] 📅 Scheduling daily alarm '\(title)' for \(hour):\(String(format: "%02d", minute))")
        
        center.add(request) { [weak self] error in
            if let error = error {
                print("[NotificationManager] ❌ Failed to schedule daily alarm: \(error.localizedDescription)")
            } else {
                print("[NotificationManager] ✅ Successfully scheduled daily alarm for \(hour):\(String(format: "%02d", minute))")
                
                // Verify the alarm was scheduled by checking pending notifications
                self?.center.getPendingNotificationRequests { requests in
                    let count = requests.filter { $0.identifier.hasPrefix(id) }.count
                    print("[NotificationManager] 📋 Total pending notifications for \(id): \(count)")
                }
            }
        }

        // Also schedule follow-up pings just for the next occurrence to simulate persistent ringing
        scheduleFollowupsForNextOccurrence(baseId: id, title: title, hour: hour, minute: minute, weekdays: nil)
    }

    func scheduleWeeklyAlarmSeries(baseId: String, title: String, hour: Int, minute: Int, weekdays: [Int]) {
        cancelAll(withPrefix: baseId)
        let body = defaultAlarmBody(forHour: hour)

        for w in weekdays {
            var comps = DateComponents()
            comps.weekday = w
            comps.hour = hour
            comps.minute = minute

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.categoryIdentifier = Self.prayerAlarmCategoryId
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .timeSensitive
            }
            content.badge = 1

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let request = UNNotificationRequest(identifier: "\(baseId)-w\(w)", content: content, trigger: trigger)
            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule weekly alarm for weekday \(w): \(error)")
                } else {
                    print("Successfully scheduled weekly alarm for weekday \(w) at \(hour):\(minute)")
                }
            }
        }

        // Schedule follow-ups for the next upcoming weekday occurrence
        scheduleFollowupsForNextOccurrence(baseId: baseId, title: title, hour: hour, minute: minute, weekdays: weekdays)
    }

    func scheduleOneOffReminder(id: String, title: String, body: String?, date: Date) {
        cancelNotification(id: id)

        let content = UNMutableNotificationContent()
        content.title = title
        if let body = body, !body.isEmpty {
            content.body = body
        }
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }

    func cancelAll(withPrefix prefix: String) {
        center.getPendingNotificationRequests { [weak self] requests in
            let ids = requests.map { $0.identifier }.filter { $0.hasPrefix(prefix) }
            guard !ids.isEmpty else { return }
            self?.center.removePendingNotificationRequests(withIdentifiers: ids)
            self?.center.removeDeliveredNotifications(withIdentifiers: ids)
        }
    }

    // MARK: - Categories & Delegate

    static let prayerAlarmCategoryId = "PRAYER_ALARM"
    static let snoozeActionId = "SNOOZE_5_MIN"
    static let snooze10ActionId = "SNOOZE_10_MIN"
    static let snooze15ActionId = "SNOOZE_15_MIN"

    func registerCategoriesAndDelegate() {
        center.delegate = self
        let snooze = UNNotificationAction(identifier: Self.snoozeActionId, title: "Give me five minutes", options: [])
        let snooze10 = UNNotificationAction(identifier: Self.snooze10ActionId, title: "Snooze 10 min", options: [])
        let snooze15 = UNNotificationAction(identifier: Self.snooze15ActionId, title: "Snooze 15 min", options: [])
        let openApp = UNNotificationAction(identifier: "OPEN_PRAYER", title: "Start the Fire", options: [.foreground])
        var options: UNNotificationCategoryOptions = [.customDismissAction, .hiddenPreviewsShowTitle]
        #if os(iOS)
        options.insert(.allowInCarPlay)
        #endif
        let category = UNNotificationCategory(
            identifier: Self.prayerAlarmCategoryId,
            actions: [openApp, snooze, snooze10, snooze15],
            intentIdentifiers: [],
            options: options
        )
        center.setNotificationCategories([category])
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    // Ensure notifications alert & make sound even when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound])
        }
        // Also trigger in-app ringer overlay for clear call-to-action when foreground
        if notification.request.content.categoryIdentifier == Self.prayerAlarmCategoryId {
            Task { @MainActor in
                AlarmRingerManager.shared.triggerNow(title: notification.request.content.title,
                                                     sourceId: notification.request.identifier)
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "OPEN_PRAYER" {
            // Bridge to app intent flow with a default duration
            let value = max(1, min(180, UserDefaults.standard.integer(forKey: "settings.defaultSessionMinutes")))
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "intent.startPrayer.timestamp")
            UserDefaults.standard.set(value > 0 ? value : 20, forKey: "intent.startPrayer.minutes")
        } else if response.actionIdentifier == Self.snoozeActionId || response.actionIdentifier == Self.snooze10ActionId || response.actionIdentifier == Self.snooze15ActionId {
            // Snooze: fire a one-off in 5 minutes using same title
            let content = response.notification.request.content
            let id = response.notification.request.identifier + "-snooze"
            let interval: TimeInterval =
                (response.actionIdentifier == Self.snooze15ActionId) ? 15 * 60 :
                (response.actionIdentifier == Self.snooze10ActionId) ? 10 * 60 : 5 * 60
            let date = Date().addingTimeInterval(interval)
            scheduleOneOffReminder(id: id, title: content.title, body: content.body, date: date)
        }

        // Cancel any next-occurrence followups once user interacts
        let basePrefix = baseIdPrefix(from: response.notification.request.identifier)
        cancelFollowups(baseId: basePrefix)
        completionHandler()
    }
}

// MARK: - Debug helpers
extension NotificationManager {
    /// Prints pending notification requests for diagnostics
    func debugLogPendingRequests() {
        center.getNotificationSettings { settings in
            print("\n[NotificationManager] 🔍 NOTIFICATION DIAGNOSTICS")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 Authorization Status: \(settings.authorizationStatus.rawValue)")
            print("🔔 Alert Setting: \(settings.alertSetting.rawValue)")
            print("🔊 Sound Setting: \(settings.soundSetting.rawValue)")  
            print("⚡ Time Sensitive: \(settings.timeSensitiveSetting.rawValue)")
            print("🔴 Critical Alert: \(settings.criticalAlertSetting.rawValue)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            self.center.getPendingNotificationRequests { requests in
                print("📅 Total Pending Notifications: \(requests.count)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                if requests.isEmpty {
                    print("⚠️  NO PENDING NOTIFICATIONS! This might be why alarms don't work outside the app.")
                    print("💡 Try scheduling a test alarm and check if it appears here.")
                } else {
                    for r in requests {
                        print("\n📌 ID: \(r.identifier)")
                        print("   📄 Title: \(r.content.title)")
                        print("   💬 Body: \(r.content.body)")
                        print("   🔔 Category: \(r.content.categoryIdentifier)")
                        
                        if #available(iOS 15.0, *) {
                            print("   ⚡ Interruption Level: \(r.content.interruptionLevel.rawValue)")
                        }
                        
                        if let cal = r.trigger as? UNCalendarNotificationTrigger {
                            if let next = cal.nextTriggerDate() {
                                let formatter = DateFormatter()
                                formatter.dateStyle = .short
                                formatter.timeStyle = .short
                                print("   📅 Next Fire: \(formatter.string(from: next))")
                            }
                            print("   🔄 Repeats: \(cal.repeats)")
                        } else if let ti = r.trigger as? UNTimeIntervalNotificationTrigger {
                            print("   ⏱️  Fires in: ~\(Int(ti.timeInterval))s")
                            print("   🔄 Repeats: \(ti.repeats)")
                        }
                        print("   ─────────────────────────────────────────────")
                    }
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            }
        }
    }

    /// Schedule a quick test alarm after a short delay to validate behavior
    func scheduleTestAlarm(after seconds: TimeInterval = 5) {
        let testId = "test-alarm-\(UUID().uuidString)"
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Test Prayer Alarm"
        content.body = "If you see this notification outside the app, system notifications are working!"
        content.categoryIdentifier = Self.prayerAlarmCategoryId
        content.sound = .default
        content.badge = 1
        content.threadIdentifier = "test-alarms"
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }
        
        content.userInfo = [
            "testId": testId,
            "scheduledFor": Date().addingTimeInterval(seconds).timeIntervalSince1970,
            "type": "test-alarm"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: testId, content: content, trigger: trigger)
        
        print("[NotificationManager] 🧪 Scheduling test alarm in \(seconds) seconds...")
        print("[NotificationManager] 💡 IMPORTANT: Background the app now to test if notifications work outside the app!")
        
        center.add(request) { error in
            if let error = error {
                print("[NotificationManager] ❌ Failed to schedule test alarm: \(error.localizedDescription)")
            } else {
                print("[NotificationManager] ✅ Test alarm scheduled successfully")
                print("[NotificationManager] 📱 Minimize or close the app to test system notifications!")
            }
        }
    }

    // MARK: - Follow-up helpers
    /// Schedule a few additional one-off notifications after the next occurrence time to simulate repeated ringing
    func scheduleFollowupsForNextOccurrence(baseId: String, title: String, hour: Int, minute: Int, weekdays: [Int]?) {
        guard let next = nextOccurrenceDate(hour: hour, minute: minute, weekdays: weekdays) else { return }
        let followupOffsets: [TimeInterval] = [30, 60, 120] // seconds after the main alarm

        for (i, offset) in followupOffsets.enumerated() {
            let fireDate = Date(timeInterval: offset, since: next)
            let key = dateKey(for: next)
            let id = "\(baseId)-fup-\(key)-\(i+1)"
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = "Reminder: It's time to pray."
            content.categoryIdentifier = Self.prayerAlarmCategoryId
            content.sound = .default
            if #available(iOS 15.0, *) { content.interruptionLevel = .timeSensitive }

            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }
    }

    private func nextOccurrenceDate(hour: Int, minute: Int, weekdays: [Int]?) -> Date? {
        let cal = Calendar.current
        let now = Date()
        if let weekdays, !weekdays.isEmpty {
            // Find the soonest date for provided weekday numbers (Sun=1 .. Sat=7)
            var best: Date?
            for w in weekdays {
                var comps = cal.dateComponents([.year, .month, .day, .weekday], from: now)
                comps.weekday = w
                comps.hour = hour
                comps.minute = minute
                if let candidate = cal.nextDate(after: now, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents) {
                    if best == nil || candidate < best! { best = candidate }
                }
            }
            return best
        } else {
            var comps = cal.dateComponents([.year, .month, .day], from: now)
            comps.hour = hour
            comps.minute = minute
            let today = cal.date(from: comps) ?? now
            return today > now ? today : cal.date(byAdding: .day, value: 1, to: today)
        }
    }

    private func dateKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmm"
        return f.string(from: date)
    }

    private func baseIdPrefix(from identifier: String) -> String {
        // For weekly ids like "<base>-w<weekday>", strip the dash suffix; for daily, return as is
        if let range = identifier.range(of: "-w") {
            return String(identifier[..<range.lowerBound])
        }
        if let range = identifier.range(of: "-fup-") {
            return String(identifier[..<range.lowerBound])
        }
        if let range = identifier.range(of: "-snooze") {
            return String(identifier[..<range.lowerBound])
        }
        return identifier
    }

    private func cancelFollowups(baseId: String) {
        center.getPendingNotificationRequests { [weak self] requests in
            let ids = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(baseId + "-fup-") }
            guard !ids.isEmpty else { return }
            self?.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    // Expose followup cancellation for in-app ringer to stop next pings
    func cancelFollowupsPublic(baseId: String) {
        cancelFollowups(baseId: baseId)
    }
}
