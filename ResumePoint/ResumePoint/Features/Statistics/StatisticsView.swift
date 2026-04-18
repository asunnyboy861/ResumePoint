import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel

    init(statisticsService: StatisticsCalculating) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(statisticsService: statisticsService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.standardPadding) {
                    overviewCards
                    platformChart
                    weeklyActivityChart
                    completionSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Statistics")
            .task {
                await viewModel.loadStatistics()
            }
            .refreshable {
                await viewModel.loadStatistics()
            }
        }
    }

    private var overviewCards: some View {
        HStack(spacing: 12) {
            StatCardView(
                title: "Total",
                value: "\(viewModel.totalVideos)",
                icon: "play.rectangle.on.rectangle",
                color: .blue
            )

            StatCardView(
                title: "Completed",
                value: "\(viewModel.completedVideos)",
                icon: "checkmark.circle.fill",
                color: .green
            )

            StatCardView(
                title: "In Progress",
                value: "\(viewModel.inProgressVideos)",
                icon: "clock",
                color: .orange
            )
        }
    }

    private var platformChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Platform")
                .font(.headline)

            if viewModel.platformStats.isEmpty {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(viewModel.platformStats) { stat in
                    BarMark(
                        x: .value("Platform", stat.platform.displayName),
                        y: .value("Videos", stat.count)
                    )
                    .foregroundStyle(Color(hex: stat.platform.accentColor).gradient)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
            }
        }
        .cardStyle()
    }

    private var weeklyActivityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            if viewModel.weeklyActivity.allSatisfy({ $0.videoCount == 0 }) {
                Text("No activity this week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(viewModel.weeklyActivity) { day in
                    BarMark(
                        x: .value("Day", day.label),
                        y: .value("Videos", day.videoCount)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 160)
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 3)) { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
            }
        }
        .cardStyle()
    }

    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Overview")
                .font(.headline)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    statRow(label: "Avg. Progress", value: "\(Int(viewModel.averageProgress))%")
                    statRow(label: "Completion Rate", value: "\(Int(viewModel.completionRate))%")
                    statRow(label: "Total Watch Time", value: viewModel.totalWatchTime)
                }

                Spacer()

                ProgressRing(
                    progress: viewModel.completionRate,
                    lineWidth: 8,
                    size: 80,
                    color: .green
                )
            }
        }
        .cardStyle()
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title.weight(.bold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle(padding: 12)
    }
}
