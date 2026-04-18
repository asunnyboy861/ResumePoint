import AppIntents
import SwiftUI

struct ContinueWatchingIntent: AppIntent {
    static var title: LocalizedStringResource = "Continue Watching"
    static var description = IntentDescription("Open your most recently watched video")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let container = DependencyContainer.current
        guard let storageService = container?.storageService else {
            return .result()
        }

        let videos = try? await storageService.fetchAll()
        let inProgress = videos?.filter { !$0.isCompleted }
            .sorted { $0.lastUpdated > $1.lastUpdated }

        if let video = inProgress?.first {
            NotificationCenter.default.post(
                name: .openVideoDetail,
                object: nil,
                userInfo: ["videoId": video.id]
            )
        }

        return .result()
    }
}

struct AddVideoIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Video to ResumePoint"
    static var description = IntentDescription("Add a new video to track your watching progress")
    static var openAppWhenRun = true

    @Parameter(title: "Video Title", description: "The title of the video")
    var videoTitle: String

    @Parameter(title: "Platform", description: "The streaming platform", default: "Other")
    var platformName: String

    @Parameter(title: "Current Position (minutes)", description: "How far you've watched in minutes", default: 0.0)
    var currentPositionMinutes: Double

    @Parameter(title: "Total Duration (minutes)", description: "Total video duration in minutes", default: 60.0)
    var totalDurationMinutes: Double

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let container = DependencyContainer.current
        guard let storageService = container?.storageService else {
            return .result(value: false)
        }

        let platform = StreamingPlatform.fromDisplayName(platformName)
        let currentPosition = currentPositionMinutes * 60
        let totalDuration = totalDurationMinutes * 60

        _ = try? await storageService.addVideo(
            title: videoTitle,
            platform: platform,
            currentPosition: currentPosition,
            totalDuration: totalDuration,
            notes: nil
        )

        return .result(value: true)
    }
}

struct ShowStatisticsIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Watching Statistics"
    static var description = IntentDescription("View your watching progress statistics")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .showStatistics, object: nil)
        return .result()
    }
}

struct MarkCompleteIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Video as Completed"
    static var description = IntentDescription("Mark your most recently watched video as completed")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let container = DependencyContainer.current
        guard let storageService = container?.storageService else {
            return .result(value: false)
        }

        let videos = try? await storageService.fetchAll()
        let inProgress = videos?.filter { !$0.isCompleted }
            .sorted { $0.lastUpdated > $1.lastUpdated }

        guard let video = inProgress?.first else {
            return .result(value: false)
        }

        try? await storageService.markCompleted(video)
        return .result(value: true)
    }
}

struct ResumePointShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ContinueWatchingIntent(),
            phrases: [
                "Continue watching on \(.applicationName)",
                "Resume my video on \(.applicationName)",
                "Open last video on \(.applicationName)"
            ],
            shortTitle: "Continue Watching",
            systemImageName: "play.circle.fill"
        )

        AppShortcut(
            intent: AddVideoIntent(),
            phrases: [
                "Add video to \(.applicationName)",
                "Track a video on \(.applicationName)"
            ],
            shortTitle: "Add Video",
            systemImageName: "plus.circle.fill"
        )

        AppShortcut(
            intent: ShowStatisticsIntent(),
            phrases: [
                "Show my stats on \(.applicationName)",
                "View watching statistics on \(.applicationName)"
            ],
            shortTitle: "Statistics",
            systemImageName: "chart.bar.fill"
        )

        AppShortcut(
            intent: MarkCompleteIntent(),
            phrases: [
                "Mark video complete on \(.applicationName)",
                "Finish video on \(.applicationName)"
            ],
            shortTitle: "Mark Complete",
            systemImageName: "checkmark.circle.fill"
        )
    }
}

extension Notification.Name {
    static let openVideoDetail = Notification.Name("openVideoDetail")
    static let showStatistics = Notification.Name("showStatistics")
}
