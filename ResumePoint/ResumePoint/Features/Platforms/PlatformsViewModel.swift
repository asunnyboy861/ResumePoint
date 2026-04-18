import SwiftUI

@MainActor
final class PlatformsViewModel: ObservableObject {
    @Published var platforms: [(StreamingPlatform, Int)] = []
    @Published var selectedPlatform: StreamingPlatform?
    @Published var videosForPlatform: [VideoProgress] = []

    private let storageService: ProgressStoring

    init(storageService: ProgressStoring) {
        self.storageService = storageService
    }

    func loadPlatforms() async {
        var platformCounts: [(StreamingPlatform, Int)] = []
        for platform in StreamingPlatform.allCases {
            let videos = (try? await storageService.fetchByPlatform(platform)) ?? []
            if !videos.isEmpty {
                platformCounts.append((platform, videos.count))
            }
        }
        platforms = platformCounts.sorted { $0.1 > $1.1 }
    }

    func selectPlatform(_ platform: StreamingPlatform) async {
        selectedPlatform = platform
        videosForPlatform = (try? await storageService.fetchByPlatform(platform)) ?? []
    }
}
