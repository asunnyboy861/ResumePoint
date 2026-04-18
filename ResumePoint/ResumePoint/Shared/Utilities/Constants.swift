import Foundation

enum Constants {
    enum Monitoring {
        static let foregroundInterval: TimeInterval = 5.0
        static let backgroundInterval: TimeInterval = 30.0
    }

    enum Storage {
        static let freeTierLimit = 50
        static let maxTitleLength = 200
        static let maxNotesLength = 1000
    }

    enum UI {
        static let defaultCornerRadius: CGFloat = 20
        static let compactCornerRadius: CGFloat = 12
        static let standardPadding: CGFloat = 16
        static let compactPadding: CGFloat = 8
    }

    enum Sync {
        static let syncTimeout: TimeInterval = 30.0
        static let maxRetries = 3
    }

    enum Notification {
        static let defaultReminderInterval: TimeInterval = 3600 * 24
    }
}
