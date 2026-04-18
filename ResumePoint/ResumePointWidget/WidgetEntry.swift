import WidgetKit
import SwiftUI

struct VideoProgressEntry: TimelineEntry {
    let date: Date
    let videos: [WidgetVideoItem]

    static var placeholder: VideoProgressEntry {
        VideoProgressEntry(
            date: .now,
            videos: WidgetVideoItem.placeholderData
        )
    }
}

struct WidgetVideoItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let platform: String
    let platformIcon: String
    let platformColor: String
    let progressPercentage: Double
    let currentPosition: Double
    let totalDuration: Double
    let lastUpdated: Date

    static var placeholderData: [WidgetVideoItem] {
        [
            WidgetVideoItem(
                id: UUID(),
                title: "Stranger Things S4E1",
                platform: "Netflix",
                platformIcon: "n.square.fill",
                platformColor: "E50914",
                progressPercentage: 65,
                currentPosition: 2400,
                totalDuration: 3600,
                lastUpdated: Date()
            )
        ]
    }
}
