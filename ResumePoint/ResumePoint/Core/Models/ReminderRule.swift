import Foundation

enum ReminderRule: String, CaseIterable, Identifiable, Codable {
    case longTimeNoWatch = "longTimeNoWatch"
    case nearCompletion = "nearCompletion"
    case newEpisode = "newEpisode"
    case weeklyDigest = "weeklyDigest"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .longTimeNoWatch: return "Long Time No Watch"
        case .nearCompletion: return "Near Completion"
        case .newEpisode: return "New Episode"
        case .weeklyDigest: return "Weekly Digest"
        }
    }

    var description: String {
        switch self {
        case .longTimeNoWatch: return "Remind when haven't watched for 7 days"
        case .nearCompletion: return "Remind when progress > 90%"
        case .newEpisode: return "Remind when new episode available"
        case .weeklyDigest: return "Weekly watching summary"
        }
    }

    var icon: String {
        switch self {
        case .longTimeNoWatch: return "clock.arrow.circlepath"
        case .nearCompletion: return "flag.checkered"
        case .newEpisode: return "sparkles"
        case .weeklyDigest: return "calendar.badge.clock"
        }
    }
}
