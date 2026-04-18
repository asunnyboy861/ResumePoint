import Foundation
import CoreData

protocol ProgressRepositoryProtocol {
    func fetchAll() async throws -> [VideoProgress]
    func fetch(by predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [VideoProgress]
    func fetch(byId id: UUID) async throws -> VideoProgress?
    func save() async throws
    func delete(_ progress: VideoProgress) async throws
    func count() async throws -> Int
    func count(predicate: NSPredicate?) async throws -> Int
    func createVideoProgress() -> VideoProgress
    var viewContext: NSManagedObjectContext { get }
}

final class ProgressRepositoryImpl: ProgressRepositoryProtocol {
    private let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func fetchAll() async throws -> [VideoProgress] {
        let request = VideoProgress.fetchRequest() as NSFetchRequest<VideoProgress>
        request.sortDescriptors = [NSSortDescriptor(keyPath: \VideoProgress.lastUpdated, ascending: false)]
        return try viewContext.fetch(request)
    }

    func fetch(by predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [VideoProgress] {
        let request = VideoProgress.fetchRequest() as NSFetchRequest<VideoProgress>
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors ?? [NSSortDescriptor(keyPath: \VideoProgress.lastUpdated, ascending: false)]
        return try viewContext.fetch(request)
    }

    func fetch(byId id: UUID) async throws -> VideoProgress? {
        let request = VideoProgress.fetchRequest() as NSFetchRequest<VideoProgress>
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }

    func save() async throws {
        guard viewContext.hasChanges else { return }
        try viewContext.save()
    }

    func delete(_ progress: VideoProgress) async throws {
        viewContext.delete(progress)
        try viewContext.save()
    }

    func count() async throws -> Int {
        let request = VideoProgress.fetchRequest() as NSFetchRequest<VideoProgress>
        return try viewContext.count(for: request)
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        let request = VideoProgress.fetchRequest() as NSFetchRequest<VideoProgress>
        request.predicate = predicate
        return try viewContext.count(for: request)
    }

    func createVideoProgress() -> VideoProgress {
        VideoProgress(context: viewContext)
    }
}
