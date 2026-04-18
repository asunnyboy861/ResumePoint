import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var videos: [VideoProgress] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var filterPlatform: StreamingPlatform?

    private let storageService: ProgressStoring
    private var cancellables = Set<AnyCancellable>()

    init(storageService: ProgressStoring) {
        self.storageService = storageService
        bindStorage()
    }

    private func bindStorage() {
        storageService.videos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] videos in
                self?.videos = videos
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    var filteredVideos: [VideoProgress] {
        var result = videos

        if let platform = filterPlatform {
            result = result.filter { $0.streamingPlatform == platform }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var inProgressVideos: [VideoProgress] {
        filteredVideos.filter { !$0.isCompleted }
    }

    var completedVideos: [VideoProgress] {
        filteredVideos.filter { $0.isCompleted }
    }

    func loadVideos() async {
        isLoading = true
        _ = try? await storageService.fetchAll()
    }

    func deleteVideo(_ video: VideoProgress) async {
        try? await storageService.deleteVideo(video)
    }

    func setFilter(_ platform: StreamingPlatform?) {
        filterPlatform = platform
    }
}
