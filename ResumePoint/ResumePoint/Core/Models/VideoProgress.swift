import Foundation
import CoreData

@objc(VideoProgress)
public class VideoProgress: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var platform: String
    @NSManaged public var currentPosition: Double
    @NSManaged public var totalDuration: Double
    @NSManaged public var lastUpdated: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var coverImageURL: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var sessions: NSSet?
}

extension VideoProgress {
    var progressPercentage: Double {
        guard totalDuration > 0 else { return 0 }
        return min((currentPosition / totalDuration) * 100, 100)
    }

    var remainingTime: Double {
        max(totalDuration - currentPosition, 0)
    }

    var formattedCurrentPosition: String {
        currentPosition.formattedTime()
    }

    var formattedTotalDuration: String {
        totalDuration.formattedTime()
    }

    var streamingPlatform: StreamingPlatform {
        StreamingPlatform(rawValue: platform) ?? .other
    }

    var sessionArray: [WatchingSession] {
        let set = sessions as? Set<WatchingSession> ?? []
        return set.sorted { $0.startTime > $1.startTime }
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoProgress> {
        return NSFetchRequest<VideoProgress>(entityName: "VideoProgress")
    }
}
