import Foundation
import CoreData

@objc(WatchingSession)
public class WatchingSession: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date
    @NSManaged public var progressChange: Double
    @NSManaged public var video: VideoProgress?
}

extension WatchingSession {
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        duration.formattedTime()
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchingSession> {
        return NSFetchRequest<WatchingSession>(entityName: "WatchingSession")
    }
}
