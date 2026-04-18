import SwiftUI

@main
struct ResumePointApp: App {
    @StateObject private var dependencies = DependencyContainer()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView(dependencies: dependencies)
            } else {
                OnboardingView()
                    .environment(\.managedObjectContext, dependencies.persistentContainer.viewContext)
            }
        }
    }
}
