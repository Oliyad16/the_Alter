//
//  NotificationNames.swift
//  The Alter beta 2
//
//  Custom notification names for app-wide events
//

import Foundation

extension Notification.Name {
    /// Posted when one or more achievements are unlocked
    /// UserInfo contains "achievements" key with [Achievement] array
    static let achievementsUnlocked = Notification.Name("achievementsUnlocked")
}
