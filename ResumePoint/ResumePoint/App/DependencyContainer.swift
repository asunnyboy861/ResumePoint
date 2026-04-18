import SwiftUI
import CoreData

@MainActor
final class DependencyContainer: ObservableObject {
    let persistentContainer: NSPersistentContainer
    let progressRepository: ProgressRepositoryProtocol
    let sessionRepository: SessionRepositoryProtocol
    let playbackMonitor: PlaybackMonitorService
    let storageService: ProgressStorageService
    let notificationService: NotificationServicing
    let reminderService: SmartReminderService
    let statisticsService: StatisticsCalculating

    private var _liveActivityService: Any?

    @available(iOS 16.2, *)
    var liveActivityService: LiveActivityService {
        _liveActivityService as! LiveActivityService
    }

    static var current: DependencyContainer!

    init() {
        let model = CoreDataStack.createModel()
        let container = NSPersistentContainer(name: "ResumePointDataModel", managedObjectModel: model)

        let storeURL = AppGroupConstants.sharedContainerURL
            .appendingPathComponent("ResumePointDataModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.persistentContainer = container

        self.progressRepository = ProgressRepositoryImpl(container: container)
        self.sessionRepository = SessionRepositoryImpl(container: container)
        self.playbackMonitor = PlaybackMonitorService()
        self.notificationService = NotificationService()
        self.reminderService = SmartReminderService(notificationService: notificationService)
        self.storageService = ProgressStorageService(
            repository: progressRepository,
            playbackMonitor: playbackMonitor
        )
        self.statisticsService = StatisticsService(repository: progressRepository)

        if #available(iOS 16.2, *) {
            _liveActivityService = LiveActivityService()
        }

        DependencyContainer.current = self
    }

    static var preview: DependencyContainer {
        let container = DependencyContainer()
        let context = container.persistentContainer.viewContext
        for i in 1...5 {
            let video = VideoProgress(context: context)
            video.id = UUID()
            video.title = "Sample Video \(i)"
            video.platform = StreamingPlatform.allCases[i % StreamingPlatform.allCases.count].rawValue
            video.currentPosition = Double.random(in: 300...3600)
            video.totalDuration = 7200
            video.lastUpdated = Date().addingTimeInterval(-Double.random(in: 0...86400))
            video.isCompleted = false
            video.createdAt = Date().addingTimeInterval(-Double.random(in: 86400...604800))
        }
        try? context.save()
        return container
    }
}
