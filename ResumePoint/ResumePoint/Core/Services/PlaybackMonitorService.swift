import Foundation
import MediaPlayer
import Combine

protocol PlaybackMonitoring {
    var currentPlayback: AnyPublisher<PlaybackInfo?, Never> { get }
    var isMonitoring: Bool { get }
    func startMonitoring()
    func stopMonitoring()
}

final class PlaybackMonitorService: PlaybackMonitoring, ObservableObject {
    @Published private var _currentPlayback: PlaybackInfo?
    @Published var isMonitoring = false

    var currentPlayback: AnyPublisher<PlaybackInfo?, Never> {
        $_currentPlayback.eraseToAnyPublisher()
    }

    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupAppLifecycleObservers()
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        checkNowPlayingInfo()
        timer = Timer.scheduledTimer(
            withTimeInterval: Constants.Monitoring.foregroundInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkNowPlayingInfo()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }

    private func setupAppLifecycleObservers() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in self?.startMonitoring() }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.handleBackgroundTransition() }
            .store(in: &cancellables)
    }

    private func handleBackgroundTransition() {
    }

    private func checkNowPlayingInfo() {
        guard let nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo else {
            DispatchQueue.main.async { [weak self] in
                self?._currentPlayback = nil
            }
            return
        }

        let title = nowPlayingInfo[MPMediaItemPropertyTitle] as? String
        let artist = nowPlayingInfo[MPMediaItemPropertyArtist] as? String
        let album = nowPlayingInfo[MPMediaItemPropertyAlbumTitle] as? String
        let duration = nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] as? Double ?? 0
        let elapsedTime = nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? Double ?? 0
        let playbackRate = nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] as? Double ?? 0

        guard playbackRate > 0 else {
            DispatchQueue.main.async { [weak self] in
                self?._currentPlayback = nil
            }
            return
        }

        let info = PlaybackInfo(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            elapsedTime: elapsedTime,
            playbackRate: playbackRate,
            timestamp: Date()
        )

        DispatchQueue.main.async { [weak self] in
            self?._currentPlayback = info
        }
    }
}
