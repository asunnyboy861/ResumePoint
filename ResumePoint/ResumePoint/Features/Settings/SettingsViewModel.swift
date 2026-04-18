import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isMonitoringEnabled = true
    @Published var isNotificationsEnabled = false
    @Published var selectedAppearance: AppearanceMode = .system
    @Published var videoCount: Int = 0
    @Published var isExporting = false
    @Published var selectedExportFormat: ExportFormat = .json

    private let storageService: ProgressStoring
    private let notificationService: NotificationServicing
    private let playbackMonitor: PlaybackMonitorService
    let reminderService: SmartReminderService

    enum AppearanceMode: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"

        var displayName: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
    }

    init(
        storageService: ProgressStoring,
        notificationService: NotificationServicing,
        playbackMonitor: PlaybackMonitorService,
        reminderService: SmartReminderService
    ) {
        self.storageService = storageService
        self.notificationService = notificationService
        self.playbackMonitor = playbackMonitor
        self.reminderService = reminderService
        loadPreferences()
    }

    func toggleMonitoring() {
        if isMonitoringEnabled {
            playbackMonitor.startMonitoring()
        } else {
            playbackMonitor.stopMonitoring()
        }
        savePreference(key: "isMonitoringEnabled", value: isMonitoringEnabled)
    }

    func toggleNotifications() async {
        if isNotificationsEnabled {
            let granted = try? await notificationService.requestPermission()
            isNotificationsEnabled = granted ?? false
        } else {
            notificationService.removeAllPendingNotifications()
        }
        savePreference(key: "isNotificationsEnabled", value: isNotificationsEnabled)
    }

    func loadStats() async {
        videoCount = (try? await storageService.videoCount()) ?? 0
    }

    func exportData() async -> Data? {
        isExporting = true
        let data = try? await storageService.export(format: selectedExportFormat)
        isExporting = false
        return data
    }

    func exportData(format: ExportFormat) async -> Data? {
        isExporting = true
        let data = try? await storageService.export(format: format)
        isExporting = false
        return data
    }

    private func loadPreferences() {
        isMonitoringEnabled = UserDefaults.standard.bool(forKey: "isMonitoringEnabled")
        isNotificationsEnabled = UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
        if let appearanceRaw = UserDefaults.standard.string(forKey: "selectedAppearance"),
           let appearance = AppearanceMode(rawValue: appearanceRaw) {
            selectedAppearance = appearance
        }
    }

    private func savePreference(key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
