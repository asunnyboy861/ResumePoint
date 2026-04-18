import WidgetKit
import CoreData

struct VideoProgressTimelineProvider: TimelineProvider {
    typealias Entry = VideoProgressEntry

    func placeholder(in context: Context) -> VideoProgressEntry {
        .placeholder
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (VideoProgressEntry) -> Void
    ) {
        let entry = VideoProgressEntry(
            date: .now,
            videos: WidgetVideoItem.placeholderData
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<VideoProgressEntry>) -> Void
    ) {
        Task {
            let videos = await fetchRecentVideos(limit: 5)
            let entry = VideoProgressEntry(
                date: .now,
                videos: videos
            )

            let nextUpdate = Calendar.current.date(
                byAdding: .minute,
                value: 15,
                to: .now
            ) ?? .now

            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )
            completion(timeline)
        }
    }

    private func fetchRecentVideos(limit: Int) async -> [WidgetVideoItem] {
        let model = CoreDataStack.createModel()
        let container = NSPersistentContainer(
            name: "ResumePointDataModel",
            managedObjectModel: model
        )

        let storeURL = AppGroupConstants.sharedContainerURL
            .appendingPathComponent("ResumePointDataModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                print("Widget CoreData failed: \(error.localizedDescription)")
            }
        }

        let request = VideoProgress.fetchRequest() as NSFetchRequest<VideoProgress>
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \VideoProgress.lastUpdated, ascending: false)
        ]
        request.fetchLimit = limit
        request.predicate = NSPredicate(format: "isCompleted == NO")

        do {
            let results = try container.viewContext.fetch(request)
            return results.map { $0.toWidgetItem() }
        } catch {
            return []
        }
    }
}
