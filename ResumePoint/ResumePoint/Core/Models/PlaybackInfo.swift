import Foundation

struct PlaybackInfo: Equatable {
    let title: String?
    let artist: String?
    let album: String?
    let duration: TimeInterval
    let elapsedTime: TimeInterval
    let playbackRate: Double
    let timestamp: Date

    var isPlaying: Bool { playbackRate > 0 }

    var hasValidTitle: Bool {
        guard let title = title, !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        return true
    }

    var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        return min((elapsedTime / duration) * 100, 100)
    }

    var remainingTime: TimeInterval {
        max(duration - elapsedTime, 0)
    }

    static func == (lhs: PlaybackInfo, rhs: PlaybackInfo) -> Bool {
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.album == rhs.album &&
        lhs.duration == rhs.duration
    }
}
