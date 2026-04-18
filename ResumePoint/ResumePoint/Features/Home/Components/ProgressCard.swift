import SwiftUI

struct ProgressCard: View {
    let video: VideoProgress
    var onTap: (() -> Void)?

    @State private var isAppeared = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap?()
        }) {
            VStack(spacing: Constants.UI.compactPadding) {
                headerSection
                Divider()
                    .padding(.vertical, 4)
                progressSection
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 8)
        .animation(.easeOut(duration: 0.3), value: isAppeared)
        .onAppear { isAppeared = true }
    }

    private var headerSection: some View {
        HStack(spacing: Constants.UI.standardPadding) {
            ProgressRing(
                progress: video.progressPercentage,
                lineWidth: 4,
                size: 50,
                color: platformColor
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: video.streamingPlatform.iconName)
                        .font(.caption)
                        .foregroundStyle(platformColor)

                    Text(video.streamingPlatform.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(video.lastUpdated.relativeString)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                if video.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
        }
    }

    private var progressSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Watched")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(video.formattedCurrentPosition)
                    .font(.subheadline.weight(.medium))
            }

            Spacer()

            VStack(alignment: .center, spacing: 4) {
                ProgressBarView(
                    progress: video.progressPercentage,
                    color: platformColor,
                    height: 4
                )
                .frame(width: 80)
                Text("\(Int(video.progressPercentage))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Remaining")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(video.remainingTime.formattedTime())
                    .font(.subheadline.weight(.medium))
            }
        }
    }

    private var platformColor: Color {
        Color(hex: video.streamingPlatform.accentColor)
    }
}

#Preview {
    VStack {
        ProgressCard(video: {
            let context = DependencyContainer.preview.persistentContainer.viewContext
            let video = VideoProgress(context: context)
            video.id = UUID()
            video.title = "Stranger Things - Season 4 Episode 1"
            video.platform = StreamingPlatform.netflix.rawValue
            video.currentPosition = 2400
            video.totalDuration = 4800
            video.isCompleted = false
            video.lastUpdated = Date()
            video.createdAt = Date()
            return video
        }())
        .padding()
    }
}
