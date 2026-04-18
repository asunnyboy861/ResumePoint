import Foundation
import UserNotifications

protocol NotificationServicing {
    func requestPermission() async throws -> Bool
    func scheduleReminder(for video: VideoProgress, at date: Date) async throws
    func cancelReminder(for video: VideoProgress) async throws
    func removeAllPendingNotifications()
}

final class NotificationService: NotificationServicing {
    private let center = UNUserNotificationCenter.current()

    func requestPermission() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleReminder(for video: VideoProgress, at date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Continue Watching"
        content.body = "Resume \"\(video.title)\" at \(video.formattedCurrentPosition)"
        content.sound = .default
        content.userInfo = ["videoId": video.id.uuidString]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "reminder-\(video.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func cancelReminder(for video: VideoProgress) async throws {
        center.removePendingNotificationRequests(withIdentifiers: ["reminder-\(video.id.uuidString)"])
    }

    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
