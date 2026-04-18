import Foundation
import CoreData

enum CoreDataStack {
    static func createContainer() -> NSPersistentContainer {
        let model = createModel()
        let container = NSPersistentContainer(name: "ResumePointDataModel", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }

    static func createInMemoryContainer() -> NSPersistentContainer {
        let model = createModel()
        let container = NSPersistentContainer(name: "ResumePointDataModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("In-memory CoreData failed: \(error.localizedDescription)")
            }
        }
        return container
    }

    static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let videoProgressEntity = NSEntityDescription()
        videoProgressEntity.name = "VideoProgress"
        videoProgressEntity.managedObjectClassName = "ResumePoint.VideoProgress"

        let videoAttributes: [NSAttributeDescription] = [
            makeAttribute("id", type: .UUIDAttributeType),
            makeAttribute("title", type: .stringAttributeType),
            makeAttribute("platform", type: .stringAttributeType),
            makeAttribute("currentPosition", type: .doubleAttributeType, defaultValue: 0.0),
            makeAttribute("totalDuration", type: .doubleAttributeType, defaultValue: 0.0),
            makeAttribute("lastUpdated", type: .dateAttributeType),
            makeAttribute("isCompleted", type: .booleanAttributeType, defaultValue: false),
            makeAttribute("coverImageURL", type: .stringAttributeType, optional: true),
            makeAttribute("notes", type: .stringAttributeType, optional: true),
            makeAttribute("createdAt", type: .dateAttributeType),
        ]
        videoProgressEntity.properties = videoAttributes

        let sessionEntity = NSEntityDescription()
        sessionEntity.name = "WatchingSession"
        sessionEntity.managedObjectClassName = "ResumePoint.WatchingSession"

        let sessionAttributes: [NSAttributeDescription] = [
            makeAttribute("id", type: .UUIDAttributeType),
            makeAttribute("startTime", type: .dateAttributeType),
            makeAttribute("endTime", type: .dateAttributeType),
            makeAttribute("progressChange", type: .doubleAttributeType, defaultValue: 0.0),
        ]
        sessionEntity.properties = sessionAttributes

        let sessionsRelationship = NSRelationshipDescription()
        sessionsRelationship.name = "sessions"
        sessionsRelationship.destinationEntity = sessionEntity
        sessionsRelationship.isOptional = true
        sessionsRelationship.minCount = 0
        sessionsRelationship.maxCount = 0
        sessionsRelationship.deleteRule = .cascadeDeleteRule

        let videoRelationship = NSRelationshipDescription()
        videoRelationship.name = "video"
        videoRelationship.destinationEntity = videoProgressEntity
        videoRelationship.isOptional = true
        videoRelationship.maxCount = 1
        videoRelationship.deleteRule = .nullifyDeleteRule

        videoRelationship.inverseRelationship = sessionsRelationship
        sessionsRelationship.inverseRelationship = videoRelationship

        videoProgressEntity.properties += [sessionsRelationship]
        sessionEntity.properties += [videoRelationship]

        model.entities = [videoProgressEntity, sessionEntity]
        return model
    }

    private static func makeAttribute(
        _ name: String,
        type: NSAttributeType,
        optional: Bool = false,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        attr.isOptional = optional
        if let defaultValue = defaultValue {
            attr.defaultValue = defaultValue
        }
        return attr
    }
}
