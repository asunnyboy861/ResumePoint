import Foundation

enum TimeFormatter {
    static func format(seconds: Double) -> String {
        seconds.formattedTime()
    }

    static func format(duration: TimeInterval) -> String {
        duration.formattedTime()
    }

    static func format(remaining: TimeInterval) -> String {
        guard remaining > 0 else { return "0:00" }
        return remaining.formattedTime()
    }

    static func parse(timeString: String) -> TimeInterval? {
        let components = timeString.split(separator: ":").compactMap { Double($0) }
        switch components.count {
        case 2:
            return components[0] * 60 + components[1]
        case 3:
            return components[0] * 3600 + components[1] * 60 + components[2]
        default:
            return nil
        }
    }
}
