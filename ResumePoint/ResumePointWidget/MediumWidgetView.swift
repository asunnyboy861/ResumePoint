import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let videos: [WidgetVideoItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            Divider()
                .padding(.vertical, 8)

            ForEach(Array(videos.prefix(3))) { video in
                WidgetVideoRow(video: video)
                if video.id != videos.prefix(3).last?.id {
                    Divider()
                        .padding(.vertical, 6)
                }
            }
        }
        .padding(14)
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 14))
                .foregroundColor(.accentColor)

            Text("Continue Watching")
                .font(.system(size: 13, weight: .semibold))

            Spacer()

            Text("\(videos.count) videos")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

struct WidgetVideoRow: View {
    let video: WidgetVideoItem

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
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
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(Int(video.progressPercentage))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: video.platformColor))

                ProgressBarView(
                    progress: video.progressPercentage,
                    color: Color(hex: video.platformColor),
                    height: 3
                )
                .frame(width: 50)
            }
        }
    }
}
