import Foundation

enum AppGroupConstants {
    static let groupIdentifier = "group.com.zzoutuo.ResumePoint"

    static var sharedUserDefaults: UserDefaults {
        UserDefaults(suiteName: groupIdentifier) ?? .standard
    }

    static var sharedContainerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        ) ?? FileManager.default.temporaryDirectory
    }
}
