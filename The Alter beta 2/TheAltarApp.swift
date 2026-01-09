import SwiftUI
import UserNotifications

@main
struct TheAltarApp: App {
    @StateObject private var dataStore = AppDataStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if dataStore.currentUser?.onboardingCompleted == true {
                    ContentView()
                        .environmentObject(dataStore)
                } else {
                    OnboardingContainerView()
                        .environmentObject(dataStore)
                }
            }
            .tint(Color.altarSoftGold)
            .preferredColorScheme(.dark)
            .withAlarmRinger()
            .onAppear {
                setupApp()
            }
        }
    }

    private func setupApp() {
        // Create user if doesn't exist
        if dataStore.currentUser == nil {
            _ = dataStore.createUser()
        }

        // Setup notifications if onboarding completed
        if dataStore.currentUser?.onboardingCompleted == true {
            NotificationManager.shared.registerCategoriesAndDelegate()
            NotificationManager.shared.requestAuthorization { _ in }
        }
    }
}
