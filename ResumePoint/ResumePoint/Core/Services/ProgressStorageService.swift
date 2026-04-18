import Foundation
import CoreData
import Combine
import WidgetKit

protocol ProgressStoring {
    var videos: AnyPublisher<[VideoProgress], Never> { get }
    func fetchAll() async throws -> [VideoProgress]
    func addVideo(title: String, platform: StreamingPlatform, currentPosition: Double, totalDuration: Double, notes: String?) async throws -> VideoProgress
    func updateVideo(_ video: VideoProgress, currentPosition: Double) async throws
    func updateVideo(_ video: VideoProgress, notes: String?) async throws
    func markCompleted(_ video: VideoProgress) async throws
    func deleteVideo(_ video: VideoProgress) async throws
    func searchVideos(query: String) async throws -> [VideoProgress]
    func fetchByPlatform(_ platform: StreamingPlatform) async throws -> [VideoProgress]
    func videoCount() async throws -> Int
    func exportToJSON() async throws -> Data
    func exportToCSV() async throws -> Data
    func exportToPDF() async throws -> Data
    func export(format: ExportFormat) async throws -> Data
}

final class ProgressStorageService: ProgressStoring, ObservableObject {
    @Published private var _videos: [VideoProgress] = []

    var videos: AnyPublisher<[VideoProgress], Never> {
        $_videos.eraseToAnyPublisher()
    }

    private let repository: ProgressRepositoryProtocol
    private let exportService: ExportService
    private var cancellables = Set<AnyCancellable>()

    init(repository: ProgressRepositoryProtocol, playbackMonitor: PlaybackMonitoring) {
        self.repository = repository
        self.exportService = ExportService()

        playbackMonitor.currentPlayback
            .compactMap { $0 }
            .filter { $0.hasValidTitle }
            .sink { [weak self] info in
                Task { @MainActor in
                    await self?.handleNewPlaybackInfo(info)
                }
            }
            .store(in: &cancellables)

        Task { @MainActor in
            await reloadVideos()
        }
    }

    @MainActor
    func fetchAll() async throws -> [VideoProgress] {
        let result = try await repository.fetchAll()
        _videos = result
        return result
    }

    @MainActor
    func addVideo(
        title: String,
        platform: StreamingPlatform,
        currentPosition: Double,
        totalDuration: Double,
        notes: String? = nil
    ) async throws -> VideoProgress {
        let video = repository.createVideoProgress()
        video.id = UUID()
        video.title = title
        video.platform = platform.rawValue
        video.currentPosition = currentPosition
        video.totalDuration = totalDuration
        video.lastUpdated = Date()
        video.isCompleted = false
        video.createdAt = Date()
        video.notes = notes

        try await repository.save()
        await reloadVideos()
        return video
    }

    @MainActor
    func updateVideo(_ video: VideoProgress, currentPosition: Double) async throws {
        video.currentPosition = currentPosition
        video.lastUpdated = Date()
        if video.progressPercentage >= 95 {
            video.isCompleted = true
        }
        try await repository.save()
        await reloadVideos()
    }

    @MainActor
    func updateVideo(_ video: VideoProgress, notes: String?) async throws {
        video.notes = notes
        video.lastUpdated = Date()
        try await repository.save()
        await reloadVideos()
    }

    @MainActor
    func markCompleted(_ video: VideoProgress) async throws {
        video.isCompleted = true
        video.lastUpdated = Date()
        try await repository.save()
        await reloadVideos()
    }

    @MainActor
    func deleteVideo(_ video: VideoProgress) async throws {
        try await repository.delete(video)
        await reloadVideos()
    }

    @MainActor
    func searchVideos(query: String) async throws -> [VideoProgress] {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        return try await repository.fetch(by: predicate, sortDescriptors: nil)
    }

    @MainActor
    func fetchByPlatform(_ platform: StreamingPlatform) async throws -> [VideoProgress] {
        let predicate = NSPredicate(format: "platform == %@", platform.rawValue)
        return try await repository.fetch(by: predicate, sortDescriptors: nil)
    }

    @MainActor
    func videoCount() async throws -> Int {
        try await repository.count()
    }

    @MainActor
    func exportToJSON() async throws -> Data {
        let allVideos = try await repository.fetchAll()
        return try await exportService.export(videos: allVideos, format: .json)
    }

    @MainActor
    func exportToCSV() async throws -> Data {
        let allVideos = try await repository.fetchAll()
        return exportService.generateCSV(from: allVideos)
    }

    @MainActor
    func exportToPDF() async throws -> Data {
        let allVideos = try await repository.fetchAll()
        return exportService.generatePDF(from: allVideos)
    }

    @MainActor
    func export(format: ExportFormat) async throws -> Data {
        let allVideos = try await repository.fetchAll()
        return try await exportService.export(videos: allVideos, format: format)
    }

    @MainActor
    private func handleNewPlaybackInfo(_ info: PlaybackInfo) async {
        guard let title = info.title, !title.isEmpty else { return }

        let existingPredicate = NSPredicate(
            format: "title == %@ AND totalDuration == %lf",
            title, info.duration
        )

        if let existing = try? await repository.fetch(by: existingPredicate, sortDescriptors: nil).first {
            try? await updateVideo(existing, currentPosition: info.elapsedTime)
        } else {
            _ = try? await addVideo(
                title: title,
                platform: .other,
                currentPosition: info.elapsedTime,
                totalDuration: info.duration
            )
        }
    }

    @MainActor
    private func reloadVideos() async {
        _videos = (try? await repository.fetchAll()) ?? []
        WidgetCenter.shared.reloadAllTimelines()
    }
}
