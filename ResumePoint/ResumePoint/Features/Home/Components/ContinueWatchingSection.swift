import SwiftUI

struct ContinueWatchingSection: View {
    let videos: [VideoProgress]
    var onTap: ((VideoProgress) -> Void)?

    private var recentVideos: [VideoProgress] {
        let inProgress = videos.filter { !$0.isCompleted }
        return Array(inProgress.sorted { $0.lastUpdated > $1.lastUpdated }.prefix(5))
    }

    var body: some View {
        if !recentVideos.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentVideos) { video in
                            ContinueWatchingCard(video: video) {
                                onTap?(video)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accentColor)

            Text("Continue Watching")
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            Text("\(recentVideos.count) in progress")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }
}

struct ContinueWatchingCard: View {
    let video: VideoProgress
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    ProgressRing(
                        progress: video.progressPercentage,
                        lineWidth: 3,
                        size: 40,
                        color: platformColor
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(video.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 4) {
                            Image(systemName: video.streamingPlatform.iconName)
                                .font(.system(size: 10))
                                .foregroundStyle(platformColor)

                            Text(video.streamingPlatform.displayName)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 0)
                }

                ProgressBarView(
                    progress: video.progressPercentage,
                    color: platformColor,
                    height: 3
                )

                HStack {
                    Text(video.formattedCurrentPosition)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text("of")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)

                    Text(video.formattedTotalDuration)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(video.lastUpdated.relativeString)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
            .frame(width: 260)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private var platformColor: Color {
        Color(hex: video.streamingPlatform.accentColor)
    }
}
