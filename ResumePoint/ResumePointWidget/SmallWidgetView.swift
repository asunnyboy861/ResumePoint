import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let video: WidgetVideoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ProgressRing(
                    progress: video.progressPercentage,
                    lineWidth: 4,
                    size: 44,
                    color: Color(hex: video.platformColor)
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(video.title)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(2)
                        .foregroundColor(.primary)

                    Text(video.platform)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Spacer()

            HStack {
                Text("\(Int(video.progressPercentage))% watched")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: video.platformColor))
            }
        }
        .padding(12)
    }
}
