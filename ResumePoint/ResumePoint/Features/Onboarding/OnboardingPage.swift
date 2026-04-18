import Foundation
import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    static let defaultPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Your Progress",
            subtitle: "Never lose your place in movies and shows across all streaming platforms",
            icon: "play.circle.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Smart Monitoring",
            subtitle: "Automatically detects when you're watching and saves your progress",
            icon: "waveform.path",
            color: .purple
        ),
        OnboardingPage(
            title: "Get Reminders",
            subtitle: "Receive smart notifications to continue watching where you left off",
            icon: "bell.badge.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "All Your Platforms",
            subtitle: "Netflix, Disney+, Max, Prime Video, Hulu, and more in one place",
            icon: "tv.fill",
            color: .red
        )
    ]
}
