import SwiftUI

struct ContentView: View {
    @ObservedObject var dependencies: DependencyContainer
    @State private var selectedTab = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(storageService: dependencies.storageService)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            StatisticsView(statisticsService: dependencies.statisticsService)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(1)

            PlatformsView(storageService: dependencies.storageService)
                .tabItem {
                    Label("Platforms", systemImage: "tv.fill")
                }
                .tag(2)

            SearchView(storageService: dependencies.storageService)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(3)

            SettingsView(
                storageService: dependencies.storageService,
                notificationService: dependencies.notificationService,
                playbackMonitor: dependencies.playbackMonitor,
                reminderService: dependencies.reminderService
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(.accentColor)
        .onReceive(NotificationCenter.default.publisher(for: .showStatistics)) { _ in
            selectedTab = 1
        }
    }
}

#Preview {
    ContentView(dependencies: DependencyContainer.preview)
}
