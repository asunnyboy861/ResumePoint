import Foundation
import CoreData

protocol SessionRepositoryProtocol {
    func fetchSessions(for video: VideoProgress) async throws -> [WatchingSession]
    func createSession(for video: VideoProgress, startTime: Date, endTime: Date, progressChange: Double) async throws -> WatchingSession
    func delete(_ session: WatchingSession) async throws
}

final class SessionRepositoryImpl: SessionRepositoryProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func fetchSessions(for video: VideoProgress) async throws -> [WatchingSession] {
        let request = WatchingSession.fetchRequest() as NSFetchRequest<WatchingSession>
        request.predicate = NSPredicate(format: "video == %@", video)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WatchingSession.startTime, ascending: false)]
        return try container.viewContext.fetch(request)
    }

    func createSession(for video: VideoProgress, startTime: Date, endTime: Date, progressChange: Double) async throws -> WatchingSession {
        let session = WatchingSession(context: container.viewContext)
        session.id = UUID()
        session.startTime = startTime
        session.endTime = endTime
        session.progressChange = progressChange
        session.video = video
        try container.viewContext.save()
        return session
    }

    func delete(_ session: WatchingSession) async throws {
        container.viewContext.delete(session)
        try container.viewContext.save()
    }
}
