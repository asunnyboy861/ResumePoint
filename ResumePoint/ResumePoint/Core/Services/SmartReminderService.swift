import Foundation
import UserNotifications

protocol SmartReminderServicing {
    var config: ReminderConfig { get set }
    func evaluateAndSchedule(for video: VideoProgress) async throws
    func updateConfig(_ config: ReminderConfig)
    func isQuietHour() -> Bool
}

final class SmartReminderService: SmartReminderServicing, ObservableObject {
    @Published var config: ReminderConfig = .default
    private let notificationService: NotificationServicing
    private let center = UNUserNotificationCenter.current()

    init(notificationService: NotificationServicing) {
        self.notificationService = notificationService
        loadConfig()
    }

    func evaluateAndSchedule(for video: VideoProgress) async throws {
        guard !video.isCompleted else { return }

        let rules = evaluateRules(for: video)

        for rule in rules where config.enabledRules.contains(rule) {
            try await scheduleReminder(for: video, rule: rule)
        }
    }

    func updateConfig(_ config: ReminderConfig) {
        self.config = config
        saveConfig()
    }

    func isQuietHour() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= config.quietHoursStart || hour < config.quietHoursEnd
    }

    private func evaluateRules(for video: VideoProgress) -> [ReminderRule] {
        var triggeredRules: [ReminderRule] = []

        let timeSinceLastWatch = Date().timeIntervalSince(video.lastUpdated)
        if timeSinceLastWatch > config.longTimeThreshold {
            triggeredRules.append(.longTimeNoWatch)
        }

        if video.progressPercentage >= config.nearCompletionThreshold {
            triggeredRules.append(.nearCompletion)
        }

        return triggeredRules
    }

    private func scheduleReminder(for video: VideoProgress, rule: ReminderRule) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Continue Watching"
        content.body = buildBody(for: video, rule: rule)
        content.sound = .default
        content.userInfo = [
            "videoId": video.id.uuidString,
            "rule": rule.rawValue
        ]

        let trigger: UNNotificationTrigger

        switch rule {
        case .longTimeNoWatch:
            let tomorrow = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Date()
            ) ?? Date()
            var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            components.hour = 19
            trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

        case .nearCompletion:
            let nextHour = Calendar.current.date(
                byAdding: .hour,
                value: 1,
                to: Date()
            ) ?? Date()
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour],
                from: nextHour
            )
            trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

        default:
            return
        }

        let request = UNNotificationRequest(
            identifier: "reminder-\(video.id.uuidString)-\(rule.rawValue)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    private func buildBody(for video: VideoProgress, rule: ReminderRule) -> String {
        switch rule {
        case .longTimeNoWatch:
            return "You haven't watched \"\(video.title)\" in a while. Continue at \(video.formattedCurrentPosition)?"
        case .nearCompletion:
            return "Almost done! \(video.remainingTime.formattedTime()) left in \"\(video.title)\""
        default:
            return "Continue watching \"\(video.title)\""
        }
    }

    private func loadConfig() {
        guard let data = UserDefaults.standard.data(forKey: "reminderConfig"),
              let saved = try? JSONDecoder().decode(ReminderConfig.self, from: data) else {
            return
        }
        config = saved
    }

    private func saveConfig() {
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: "reminderConfig")
    }
}
