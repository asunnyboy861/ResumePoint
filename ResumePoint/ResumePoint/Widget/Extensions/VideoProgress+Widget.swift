import Foundation

extension VideoProgress {
    func toWidgetItem() -> WidgetVideoItem {
        WidgetVideoItem(
            id: id,
            title: title,
            platform: streamingPlatform.displayName,
            platformIcon: streamingPlatform.iconName,
            platformColor: streamingPlatform.accentColor,
            progressPercentage: progressPercentage,
            currentPosition: currentPosition,
            totalDuration: totalDuration,
            lastUpdated: lastUpdated
        )
    }
}
