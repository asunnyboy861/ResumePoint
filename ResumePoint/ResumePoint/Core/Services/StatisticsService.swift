import Foundation

protocol StatisticsCalculating {
    func totalVideos() async throws -> Int
    func completedVideos() async throws -> Int
    func inProgressVideos() async throws -> Int
    func averageProgress() async throws -> Double
    func totalWatchTime() async throws -> TimeInterval
    func platformBreakdown() async throws -> [PlatformStat]
    func weeklyActivity() async throws -> [DayActivity]
    func completionRate() async throws -> Double
}

struct PlatformStat: Identifiable {
    let id = UUID()
    let platform: StreamingPlatform
    let count: Int
    let averageProgress: Double
}

struct DayActivity: Identifiable {
    let id = UUID()
    let date: Date
    let videoCount: Int
    let label: String
}

final class StatisticsService: StatisticsCalculating {
    private let repository: ProgressRepositoryProtocol

    init(repository: ProgressRepositoryProtocol) {
        self.repository = repository
    }

    func totalVideos() async throws -> Int {
        try await repository.count()
    }

    func completedVideos() async throws -> Int {
        try await repository.count(predicate: NSPredicate(format: "isCompleted == YES"))
    }

    func inProgressVideos() async throws -> Int {
        try await repository.count(predicate: NSPredicate(format: "isCompleted == NO"))
    }

    func averageProgress() async throws -> Double {
        let allVideos = try await repository.fetchAll()
        guard !allVideos.isEmpty else { return 0 }
        return allVideos.reduce(0) { $0 + $1.progressPercentage } / Double(allVideos.count)
    }

    func totalWatchTime() async throws -> TimeInterval {
        let allVideos = try await repository.fetchAll()
        return allVideos.reduce(0) { $0 + $1.currentPosition }
    }

    func platformBreakdown() async throws -> [PlatformStat] {
        let allVideos = try await repository.fetchAll()
        let grouped = Dictionary(grouping: allVideos) { $0.streamingPlatform }

        return grouped.map { platform, videos in
            let avgProgress = videos.isEmpty ? 0 : videos.reduce(0) { $0 + $1.progressPercentage } / Double(videos.count)
            return PlatformStat(
                platform: platform,
                count: videos.count,
                averageProgress: avgProgress
            )
        }
        .sorted { $0.count > $1.count }
    }

    func weeklyActivity() async throws -> [DayActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let allVideos = try await repository.fetchAll()

        var activities: [DayActivity] = []
        let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let count = allVideos.filter { video in
                video.lastUpdated >= dayStart && video.lastUpdated < dayEnd
            }.count

            let weekday = calendar.component(.weekday, from: date)
            let label = dayLabels[weekday - 1]

            activities.append(DayActivity(date: date, videoCount: count, label: label))
        }

        return activities
    }

    func completionRate() async throws -> Double {
        let total = try await totalVideos()
        guard total > 0 else { return 0 }
        let completed = try await completedVideos()
        return (Double(completed) / Double(total)) * 100
    }
}
