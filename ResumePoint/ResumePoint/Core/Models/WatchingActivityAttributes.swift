import ActivityKit
import Foundation

struct WatchingActivityAttributes: ActivityAttributes {
    let videoTitle: String
    let platformName: String
    let platformColor: String

    struct ContentState: Codable, Hashable {
        let progressPercentage: Double
        let currentPosition: Double
        let totalDuration: Double
    }
}
