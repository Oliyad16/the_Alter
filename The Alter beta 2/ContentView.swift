import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab: MainTab = .home

    private enum MainTab: Hashable {
        case home
        case read
        case pray
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(MainTab.home)

            BibleReaderView()
                .tabItem {
                    Label("Read", systemImage: "book.fill")
                }
                .tag(MainTab.read)

            MeetingPlaceView()
                .tabItem {
                    Label("Pray", systemImage: "flame.fill")
                }
                .tag(MainTab.pray)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(MainTab.settings)
        }
        .tint(.altarRed)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .intentStartPrayer)) { _ in
            selectedTab = .pray
        }
    }
}
