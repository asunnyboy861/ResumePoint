import WidgetKit
import SwiftUI

struct ResumePointWidgetBundle: WidgetBundle {
    var body: some Widget {
        ResumePointWidget()
    }
}

struct ResumePointWidget: Widget {
    let kind: String = "ResumePointWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VideoProgressTimelineProvider()) { entry in
            ResumePointWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ResumePoint")
        .description("Track your watching progress at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ResumePointWidgetEntryView: View {
    let entry: VideoProgressEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            if let video = entry.videos.first {
                SmallWidgetView(video: video)
            }
        case .systemMedium:
            MediumWidgetView(videos: entry.videos)
        case .systemLarge:
            LargeWidgetView(videos: entry.videos)
        default:
            SmallWidgetView(video: entry.videos.first ?? WidgetVideoItem.placeholderData[0])
        }
    }
}

#Preview(as: .systemSmall) {
    ResumePointWidget()
} timeline: {
    VideoProgressEntry(date: .now, videos: WidgetVideoItem.placeholderData)
}

#Preview(as: .systemMedium) {
    ResumePointWidget()
} timeline: {
    VideoProgressEntry(date: .now, videos: WidgetVideoItem.placeholderData)
}

#Preview(as: .systemLarge) {
    ResumePointWidget()
} timeline: {
    VideoProgressEntry(date: .now, videos: WidgetVideoItem.placeholderData)
}
