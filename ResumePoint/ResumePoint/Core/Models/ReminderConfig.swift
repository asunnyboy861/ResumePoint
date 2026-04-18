import Foundation

struct ReminderConfig: Codable {
    var enabledRules: Set<ReminderRule>
    var longTimeThreshold: TimeInterval
    var nearCompletionThreshold: Double
    var quietHoursStart: Int
    var quietHoursEnd: Int

    static let `default` = ReminderConfig(
        enabledRules: [.longTimeNoWatch, .nearCompletion],
        longTimeThreshold: 7 * 24 * 3600,
        nearCompletionThreshold: 90.0,
        quietHoursStart: 22,
        quietHoursEnd: 8
    )
}
