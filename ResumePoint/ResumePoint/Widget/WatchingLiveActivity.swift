import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.2, *)
struct WatchingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WatchingActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: context.attributes.platformColor))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progressPercentage))%")
                        .font(.title2.monospacedDigit().bold())
                        .foregroundColor(Color(hex: context.attributes.platformColor))
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.videoTitle)
                        .font(.caption)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        ProgressBarView(
                            progress: context.state.progressPercentage,
                            color: Color(hex: context.attributes.platformColor),
                            height: 4
                        )

                        HStack {
                            Text(context.state.currentPosition.formattedTime())
                                .font(.caption2.monospacedDigit())
                            Spacer()
                            Text(context.state.totalDuration.formattedTime())
                                .font(.caption2.monospacedDigit())
                        }
                        .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(Color(hex: context.attributes.platformColor))
            } compactTrailing: {
                Text("\(Int(context.state.progressPercentage))%")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundColor(Color(hex: context.attributes.platformColor))
            } minimal: {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(Color(hex: context.attributes.platformColor))
            }
        }
    }
}

@available(iOS 16.2, *)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<WatchingActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            ProgressRing(
                progress: context.state.progressPercentage,
                lineWidth: 4,
                size: 44,
                color: Color(hex: context.attributes.platformColor)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.videoTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Text(context.attributes.platformName)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                ProgressBarView(
                    progress: context.state.progressPercentage,
                    color: Color(hex: context.attributes.platformColor),
                    height: 3
                )

                HStack {
                    Text(context.state.currentPosition.formattedTime())
                        .font(.system(size: 10, design: .monospaced))
                    Spacer()
                    Text(context.state.totalDuration.formattedTime())
                        .font(.system(size: 10, design: .monospaced))
                }
                .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
    }
}
