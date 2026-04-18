import ActivityKit
import Foundation

protocol LiveActivityManaging {
    func startActivity(video: VideoProgress) throws
    func updateActivity(video: VideoProgress) throws
    func endActivity(video: VideoProgress)
    func endAllActivities()
}

@available(iOS 16.2, *)
final class LiveActivityService: LiveActivityManaging, ObservableObject {
    private var currentActivity: Activity<WatchingActivityAttributes>?

    func startActivity(video: VideoProgress) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        endAllActivities()

        let attributes = WatchingActivityAttributes(
            videoTitle: video.title,
            platformName: video.streamingPlatform.displayName,
            platformColor: video.streamingPlatform.accentColor
        )

        let contentState = WatchingActivityAttributes.ContentState(
            progressPercentage: video.progressPercentage,
            currentPosition: video.currentPosition,
            totalDuration: video.totalDuration
        )

        let content = ActivityContent(
            state: contentState,
            staleDate: nil
        )

        currentActivity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    func updateActivity(video: VideoProgress) throws {
        guard let activity = currentActivity else { return }

        let contentState = WatchingActivityAttributes.ContentState(
            progressPercentage: video.progressPercentage,
            currentPosition: video.currentPosition,
            totalDuration: video.totalDuration
        )

        let content = ActivityContent(
            state: contentState,
            staleDate: nil
        )

        Task {
            await activity.update(content)
        }
    }

    func endActivity(video: VideoProgress) {
        guard let activity = currentActivity else { return }

        Task {
            let finalState = WatchingActivityAttributes.ContentState(
                progressPercentage: video.progressPercentage,
                currentPosition: video.currentPosition,
                totalDuration: video.totalDuration
            )

            let content = ActivityContent(
                state: finalState,
                staleDate: nil
            )

            await activity.end(content, dismissalPolicy: .after(.now + 5))
        }

        currentActivity = nil
    }

    func endAllActivities() {
        Task {
            for activity in Activity<WatchingActivityAttributes>.activities {
                let content = ActivityContent(
                    state: WatchingActivityAttributes.ContentState(
                        progressPercentage: 0,
                        currentPosition: 0,
                        totalDuration: 0
                    ),
                    staleDate: nil
                )
                await activity.end(content, dismissalPolicy: .immediate)
            }
        }
        currentActivity = nil
    }
}
