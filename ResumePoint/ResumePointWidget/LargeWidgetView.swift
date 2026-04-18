import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let videos: [WidgetVideoItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            Divider()
                .padding(.vertical, 8)

            ForEach(Array(videos.prefix(5))) { video in
                LargeWidgetVideoRow(video: video)
                if video.id != videos.prefix(5).last?.id {
                    Divider()
                        .padding(.vertical, 4)
                }
            }

            Spacer()

            statsFooter
        }
        .padding(14)
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 14))
                .foregroundColor(.accentColor)

            Text("ResumePoint")
                .font(.system(size: 14, weight: .bold))

            Spacer()

            Text("\(videos.count) in progress")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    private var statsFooter: some View {
        HStack(spacing: 16) {
            Label {
                Text("\(videos.filter { $0.progressPercentage >= 90 }.count) near done")
                    .font(.system(size: 10))
            } icon: {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 10))
            }
            .foregroundColor(.green)

            Spacer()

            Label {
                Text("Updated just now")
                    .font(.system(size: 10))
            } icon: {
                Image(systemName: "clock")
                    .font(.system(size: 10))
            }
            .foregroundColor(.secondary)
        }
    }
}

struct LargeWidgetVideoRow: View {
    let video: WidgetVideoItem

    var body: some View {
        HStack(spacing: 10) {
            ProgressRing(
                progress: video.progressPercentage,
                lineWidth: 3,
                size: 32,
                color: Color(hex: video.platformColor)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(video.title)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: video.platformIcon)
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: video.platformColor))

                    Text(video.platform)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Text("·")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Text(video.currentPosition.formattedTime())
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("\(Int(video.progressPercentage))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: video.platformColor))
        }
    }
}
