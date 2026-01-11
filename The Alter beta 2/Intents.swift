import Foundation
#if canImport(AppIntents)
import AppIntents

@available(iOS 16.0, *)
struct StartPrayerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Prayer"
    static var description = IntentDescription("Start a focused prayer timer in the app.")

    @Parameter(title: "Minutes")
    var minutes: Int?

    func perform() async throws -> some IntentResult {
        let value = max(1, min(180, minutes ?? 20))
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "intent.startPrayer.timestamp")
        UserDefaults.standard.set(value, forKey: "intent.startPrayer.minutes")
        return .result()
    }
}

@available(iOS 16.0, *)
struct AddPrayerPointIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Prayer Point"
    static var description = IntentDescription("Add a new prayer point to your altar log.")

    @Parameter(title: "Title")
    var title: String

    @Parameter(title: "Category")
    var category: String?

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "intent.addPoint.timestamp")
        UserDefaults.standard.set(title, forKey: "intent.addPoint.title")
        UserDefaults.standard.set(category ?? "", forKey: "intent.addPoint.category")
        return .result()
    }
}

@available(iOS 16.0, *)
struct TheAlterShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .orange

    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: StartPrayerIntent(),
                phrases: ["Start prayer in \(.applicationName)"],
                shortTitle: "Start Prayer",
                systemImageName: "flame.fill"
            ),
            AppShortcut(
                intent: AddPrayerPointIntent(),
                phrases: ["Add prayer in \(.applicationName)"],
                shortTitle: "Add Prayer",
                systemImageName: "book.fill"
            )
        ]
    }
}
#endif

// MARK: - Notification Extensions

extension Notification.Name {
    static let intentStartPrayer = Notification.Name("intentStartPrayer")
}
