import SwiftUI

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var video: VideoProgress
    @Published var isEditing = false
    @Published var notes = ""
    @Published var isDeleting = false

    private let storageService: ProgressStoring

    init(video: VideoProgress, storageService: ProgressStoring) {
        self.video = video
        self.storageService = storageService
        self.notes = video.notes ?? ""
    }

    func saveNotes() async {
        do {
            try await storageService.updateVideo(video, notes: notes)
            isEditing = false
        } catch {
        }
    }

    func markCompleted() async {
        do {
            try await storageService.markCompleted(video)
        } catch {
        }
    }

    func deleteVideo() async {
        isDeleting = true
        do {
            try await storageService.deleteVideo(video)
        } catch {
            isDeleting = false
        }
    }
}
