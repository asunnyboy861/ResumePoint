import SwiftUI

@MainActor
final class AddProgressViewModel: ObservableObject {
    @Published var title = ""
    @Published var selectedPlatform: StreamingPlatform = .netflix
    @Published var currentPositionHours = 0
    @Published var currentPositionMinutes = 0
    @Published var currentPositionSeconds = 0
    @Published var totalDurationHours = 0
    @Published var totalDurationMinutes = 0
    @Published var totalDurationSeconds = 0
    @Published var notes = ""
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let storageService: ProgressStoring

    init(storageService: ProgressStoring) {
        self.storageService = storageService
    }

    var currentPosition: Double {
        Double(currentPositionHours * 3600 + currentPositionMinutes * 60 + currentPositionSeconds)
    }

    var totalDuration: Double {
        Double(totalDurationHours * 3600 + totalDurationMinutes * 60 + totalDurationSeconds)
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && totalDuration > 0
    }

    func save() async -> Bool {
        guard isValid else {
            errorMessage = "Please fill in title and total duration"
            return false
        }

        isSaving = true
        errorMessage = nil

        do {
            _ = try await storageService.addVideo(
                title: title.trimmingCharacters(in: .whitespaces),
                platform: selectedPlatform,
                currentPosition: currentPosition,
                totalDuration: totalDuration,
                notes: notes.isEmpty ? nil : notes
            )
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }
}
