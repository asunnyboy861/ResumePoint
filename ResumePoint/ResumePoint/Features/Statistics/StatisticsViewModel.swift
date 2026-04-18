import SwiftUI

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var totalVideos = 0
    @Published var completedVideos = 0
    @Published var inProgressVideos = 0
    @Published var averageProgress: Double = 0
    @Published var completionRate: Double = 0
    @Published var totalWatchTime = ""
    @Published var platformStats: [PlatformStat] = []
    @Published var weeklyActivity: [DayActivity] = []
    @Published var isLoading = false

    private let statisticsService: StatisticsCalculating

    init(statisticsService: StatisticsCalculating) {
        self.statisticsService = statisticsService
    }

    func loadStatistics() async {
        isLoading = true

        do {
            async let total = statisticsService.totalVideos()
            async let completed = statisticsService.completedVideos()
            async let inProgress = statisticsService.inProgressVideos()
            async let avgProgress = statisticsService.averageProgress()
            async let rate = statisticsService.completionRate()
            async let watchTime = statisticsService.totalWatchTime()
            async let platforms = statisticsService.platformBreakdown()
            async let weekly = statisticsService.weeklyActivity()

            totalVideos = (try? await total) ?? 0
            completedVideos = (try? await completed) ?? 0
            inProgressVideos = (try? await inProgress) ?? 0
            averageProgress = (try? await avgProgress) ?? 0
            completionRate = (try? await rate) ?? 0
            totalWatchTime = (try? await watchTime)?.formattedTime() ?? "0:00"
            platformStats = (try? await platforms) ?? []
            weeklyActivity = (try? await weekly) ?? []
        }

        isLoading = false
    }
}
