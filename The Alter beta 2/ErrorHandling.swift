import Foundation
import SwiftUI
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

// MARK: - App Error Types

enum AppError: LocalizedError, Identifiable, Equatable {
    case dataCorruption(String)
    case notificationPermissionDenied
    case audioPlaybackFailed(String)
    case networkUnavailable
    case userDataLost
    case unexpectedError(String)
    
    var id: String {
        switch self {
        case .dataCorruption(let details):
            return "dataCorruption_\(details)"
        case .notificationPermissionDenied:
            return "notificationPermissionDenied"
        case .audioPlaybackFailed(let details):
            return "audioPlaybackFailed_\(details)"
        case .networkUnavailable:
            return "networkUnavailable"
        case .userDataLost:
            return "userDataLost"
        case .unexpectedError(let details):
            return "unexpectedError_\(details)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .dataCorruption(let details):
            return "Data corruption detected: \(details)"
        case .notificationPermissionDenied:
            return "Notifications are disabled for The Alter"
        case .audioPlaybackFailed(let details):
            return "Audio playback failed: \(details)"
        case .networkUnavailable:
            return "Network connection is not available"
        case .userDataLost:
            return "Some user data may have been lost"
        case .unexpectedError(let details):
            return "An unexpected error occurred: \(details)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataCorruption:
            return "Your data will be restored from backup. Some recent changes may be lost."
        case .notificationPermissionDenied:
            return "Go to Settings > Notifications > The Alter to enable prayer reminders."
        case .audioPlaybackFailed:
            return "Check your volume settings and try again. Ensure you have enough storage space."
        case .networkUnavailable:
            return "Please check your internet connection and try again."
        case .userDataLost:
            return "We've restored what we could. You may need to recreate some prayer points."
        case .unexpectedError:
            return "Please restart the app. If the problem persists, contact support."
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .dataCorruption, .userDataLost, .audioPlaybackFailed, .networkUnavailable:
            return true
        case .notificationPermissionDenied, .unexpectedError:
            return false
        }
    }
}

// MARK: - Error Recovery Manager

@MainActor
final class ErrorRecoveryManager: ObservableObject {
    static let shared = ErrorRecoveryManager()
    
    @Published var currentError: AppError?
    @Published var isShowingErrorAlert = false
    
    private init() {}
    
    func handleError(_ error: AppError) {
        print("🚨 [ErrorManager] Handling error: \(error.localizedDescription)")
        
        // Attempt automatic recovery first
        if error.isRecoverable {
            attemptRecovery(for: error)
        }
        
        // Show user-facing error if needed
        currentError = error
        isShowingErrorAlert = true
    }
    
    private func attemptRecovery(for error: AppError) {
        switch error {
        case .dataCorruption(let details):
            DataRecoveryService.shared.restoreFromBackup(reason: details)
            
        case .userDataLost:
            DataRecoveryService.shared.validateAndRecover()
            
        case .audioPlaybackFailed:
            AudioRecoveryService.shared.resetAudioSession()
            
        case .networkUnavailable:
            NetworkRecoveryService.shared.enableOfflineMode()
            
        default:
            break
        }
    }
    
    func dismissError() {
        currentError = nil
        isShowingErrorAlert = false
    }
}

// MARK: - Data Recovery Service

final class DataRecoveryService {
    static let shared = DataRecoveryService()
    
    private let backupPrefix = "backup_"
    private let maxBackups = 5
    
    private init() {}
    
    func createBackup(for key: String, data: Data) {
        let backupKey = "\(backupPrefix)\(key)_\(Date().timeIntervalSince1970)"
        UserDefaults.standard.set(data, forKey: backupKey)
        
        // Clean up old backups
        cleanupOldBackups(for: key)
    }
    
    func restoreFromBackup(reason: String) {
        print("🔧 [DataRecovery] Attempting data restoration: \(reason)")
        
        // Restore critical data
        restoreDataStore()
        restoreAppState()
        restoreAlarms()
        
        // Log recovery event
        logRecoveryEvent(reason: reason)
    }
    
    func validateAndRecover() {
        // Validate all critical data structures
        validatePrayerItems()
        validatePrayerSessions()
        validateAlarms()
        validateUserSettings()
    }
    
    private func restoreDataStore() {
        let keys = [
            "user.v2",
            "commitment.v2",
            "bibleProgress.v2",
            "verseActions.v2",
            "prayerSessions.v2",
            "prayerItems.v2",
            "dailyMetrics.v2",
            "alarms.v2",
            "reminders.v2"
        ]
        
        for key in keys {
            if let backupData = getLatestBackup(for: key) {
                UserDefaults.standard.set(backupData, forKey: key)
                print("✅ [DataRecovery] Restored \(key) from backup")
            }
        }
    }
    
    private func restoreAppState() {
        let keys = [
            "settings.displayName",
            "settings.dailyGoalMinutes",
            "settings.weeklyGoalMinutes"
        ]
        
        for key in keys {
            if let backupData = getLatestBackup(for: key) {
                UserDefaults.standard.set(backupData, forKey: key)
            }
        }
    }
    
    private func restoreAlarms() {
        // Ensure notification permissions are still valid
        Task { @MainActor in
            await NotificationPermissionManager.shared.checkAndRestoreNotifications()
        }
    }
    
    private func validatePrayerItems() {
        guard let data = UserDefaults.standard.data(forKey: "prayerItems.v2") else { return }
        
        do {
            let items = try JSONDecoder().decode([PrayerItem].self, from: data)
            
            // Validate each item
            let validatedItems = items.compactMap { item -> PrayerItem? in
                guard !item.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
                return item
            }
            
            // Save cleaned data
            if let cleanData = try? JSONEncoder().encode(validatedItems) {
                UserDefaults.standard.set(cleanData, forKey: "prayerItems.v2")
            }
            
        } catch {
            print("⚠️ [DataRecovery] Prayer items validation failed: \(error)")
            Task { @MainActor in
                ErrorRecoveryManager.shared.handleError(.dataCorruption("Prayer items"))
            }
        }
    }
    
    private func validatePrayerSessions() {
        guard let data = UserDefaults.standard.data(forKey: "prayerSessions.v2") else { return }
        
        do {
            let sessions = try JSONDecoder().decode([PrayerSession].self, from: data)
            
            // Remove invalid sessions (negative duration, future dates)
            let validSessions = sessions.filter { session in
                session.durationMinutes >= 0 && session.startTime <= Date()
            }
            
            if let cleanData = try? JSONEncoder().encode(validSessions) {
                UserDefaults.standard.set(cleanData, forKey: "prayerSessions.v2")
            }
            
        } catch {
            print("⚠️ [DataRecovery] Prayer sessions validation failed: \(error)")
        }
    }
    
    private func validateAlarms() {
        guard let data = UserDefaults.standard.data(forKey: "alarms.v2") else { return }
        
        do {
            let alarms = try JSONDecoder().decode([Alarm].self, from: data)
            
            // Validate alarm times
            let validAlarms = alarms.filter { alarm in
                alarm.hour >= 0 && alarm.hour <= 23 &&
                alarm.minute >= 0 && alarm.minute <= 59
            }
            
            if let cleanData = try? JSONEncoder().encode(validAlarms) {
                UserDefaults.standard.set(cleanData, forKey: "alarms.v2")
            }
            
        } catch {
            print("⚠️ [DataRecovery] Alarms validation failed: \(error)")
        }
    }
    
    private func validateUserSettings() {
        // Ensure goal values are reasonable
        let dailyGoal = UserDefaults.standard.integer(forKey: "settings.dailyGoalMinutes")
        if dailyGoal <= 0 || dailyGoal > 1440 { // Max 24 hours
            UserDefaults.standard.set(30, forKey: "settings.dailyGoalMinutes")
        }
        
        let weeklyGoal = UserDefaults.standard.integer(forKey: "settings.weeklyGoalMinutes")
        if weeklyGoal <= 0 || weeklyGoal > 10080 { // Max 1 week
            UserDefaults.standard.set(120, forKey: "settings.weeklyGoalMinutes")
        }
    }
    
    func getLatestBackup(for key: String) -> Data? {
        let backupKeys = UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("\(backupPrefix)\(key)_") }
            .sorted { $0 > $1 } // Most recent first
        
        guard let latestKey = backupKeys.first else { return nil }
        return UserDefaults.standard.data(forKey: latestKey)
    }
    
    private func cleanupOldBackups(for key: String) {
        let backupKeys = UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("\(backupPrefix)\(key)_") }
            .sorted { $0 > $1 }
        
        // Keep only the most recent backups
        if backupKeys.count > maxBackups {
            for oldKey in backupKeys.dropFirst(maxBackups) {
                UserDefaults.standard.removeObject(forKey: oldKey)
            }
        }
    }
    
    private func logRecoveryEvent(reason: String) {
        let event: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "reason": reason,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        ]
        
        // In a production app, this would be sent to analytics
        print("📊 [DataRecovery] Recovery event logged: \(event)")
    }
}

// MARK: - Audio Recovery Service

final class AudioRecoveryService {
    static let shared = AudioRecoveryService()
    
    private init() {}
    
    func resetAudioSession() {
        print("🔧 [AudioRecovery] Resetting audio session")
        
        // This would integrate with your AudioManager
        // AudioManager.shared.resetSession()
        
        // Attempt to restart background audio if needed
        // AudioManager.shared.prepareForBackgroundPlayback()
    }
}

// MARK: - Network Recovery Service

final class NetworkRecoveryService {
    static let shared = NetworkRecoveryService()
    
    @Published var isOfflineMode = false
    
    private init() {}
    
    func enableOfflineMode() {
        print("📱 [NetworkRecovery] Enabling offline mode")
        isOfflineMode = true
        
        // Disable network-dependent features
        // Show offline indicator in UI
    }
    
    func disableOfflineMode() {
        print("🌐 [NetworkRecovery] Network restored - disabling offline mode")
        isOfflineMode = false
    }
}

// MARK: - Notification Permission Manager

@MainActor
final class NotificationPermissionManager {
    static let shared = NotificationPermissionManager()
    
    private init() {}
    
    func checkAndRestoreNotifications() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .denied:
            ErrorRecoveryManager.shared.handleError(.notificationPermissionDenied)
        case .authorized, .provisional:
            // Re-register categories and delegate
            NotificationManager.shared.registerCategoriesAndDelegate()
        default:
            break
        }
    }
}

// MARK: - Error Boundary View Modifier

struct ErrorBoundary: ViewModifier {
    @StateObject private var errorManager = ErrorRecoveryManager.shared
    
    func body(content: Content) -> some View {
        content
            .alert("Something went wrong", isPresented: $errorManager.isShowingErrorAlert) {
                if let error = errorManager.currentError {
                    Button("OK") {
                        errorManager.dismissError()
                    }
                    
                    if error.isRecoverable {
                        Button("Retry") {
                            // Implement retry logic based on error type
                            errorManager.dismissError()
                        }
                    }
                    
                    if error == .notificationPermissionDenied {
                        Button("Open Settings") {
                            #if canImport(UIKit)
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                            #endif
                            errorManager.dismissError()
                        }
                    }
                }
            } message: {
                if let error = errorManager.currentError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(error.localizedDescription)
                        
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.footnote)
                        }
                    }
                }
            }
    }
}

extension View {
    func withErrorBoundary() -> some View {
        modifier(ErrorBoundary())
    }
}
