import Foundation

enum ProFeature: String, CaseIterable, Identifiable {
    case iCloudSync = "icloudSync"
    case unlimitedVideos = "unlimitedVideos"
    case smartReminders = "smartReminders"
    case exportFormats = "exportFormats"
    case widgets = "widgets"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .iCloudSync: return "iCloud Sync"
        case .unlimitedVideos: return "Unlimited Videos"
        case .smartReminders: return "Smart Reminders"
        case .exportFormats: return "All Export Formats"
        case .widgets: return "Home Screen Widgets"
        }
    }

    var icon: String {
        switch self {
        case .iCloudSync: return "icloud.fill"
        case .unlimitedVideos: return "infinity"
        case .smartReminders: return "bell.badge.fill"
        case .exportFormats: return "square.and.arrow.up.fill"
        case .widgets: return "square.grid.2x2.fill"
        }
    }

    var description: String {
        switch self {
        case .iCloudSync: return "Sync across all your devices"
        case .unlimitedVideos: return "No limit on tracked videos"
        case .smartReminders: return "Intelligent watching reminders"
        case .exportFormats: return "CSV, PDF, and JSON export"
        case .widgets: return "Quick access from home screen"
        }
    }
}
