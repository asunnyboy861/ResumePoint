import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showingExportSheet = false
    @State private var exportData: Data?
    @State private var showingFormatPicker = false

    init(
        storageService: ProgressStoring,
        notificationService: NotificationServicing,
        playbackMonitor: PlaybackMonitorService,
        reminderService: SmartReminderService
    ) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            storageService: storageService,
            notificationService: notificationService,
            playbackMonitor: playbackMonitor,
            reminderService: reminderService
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                ProSectionView()
                monitoringSection
                notificationsSection
                appearanceSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .task {
                await viewModel.loadStats()
            }
            .sheet(isPresented: $showingExportSheet) {
                if let data = exportData {
                    ShareSheet(items: [data])
                }
            }
            .sheet(isPresented: $showingFormatPicker) {
                ExportFormatPicker(selectedFormat: $viewModel.selectedExportFormat) { format in
                    Task {
                        exportData = await viewModel.exportData(format: format)
                        if exportData != nil {
                            showingExportSheet = true
                        }
                    }
                }
            }
        }
    }

    private var monitoringSection: some View {
        Section("Monitoring") {
            Toggle("Auto-detect Playback", isOn: $viewModel.isMonitoringEnabled)
                .onChange(of: viewModel.isMonitoringEnabled) { _, _ in
                    viewModel.toggleMonitoring()
                }

            HStack {
                Text("Status")
                Spacer()
                Label(
                    viewModel.isMonitoringEnabled ? "Active" : "Inactive",
                    systemImage: viewModel.isMonitoringEnabled ? "checkmark.circle.fill" : "xmark.circle"
                )
                .foregroundStyle(viewModel.isMonitoringEnabled ? .green : .secondary)
                .font(.subheadline)
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Enable Reminders", isOn: $viewModel.isNotificationsEnabled)
                .onChange(of: viewModel.isNotificationsEnabled) { _, _ in
                    Task { await viewModel.toggleNotifications() }
                }

            if viewModel.isNotificationsEnabled {
                NavigationLink {
                    ReminderSettingsView(reminderService: viewModel.reminderService)
                } label: {
                    Label("Smart Reminders", systemImage: "bell.badge")
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Appearance", selection: $viewModel.selectedAppearance) {
                ForEach(SettingsViewModel.AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var dataSection: some View {
        Section("Data") {
            HStack {
                Text("Tracked Videos")
                Spacer()
                Text("\(viewModel.videoCount)")
                    .foregroundStyle(.secondary)
            }

            Button(action: {
                showingFormatPicker = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Data")
                    Spacer()
                    Text(viewModel.selectedExportFormat.displayName)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(viewModel.isExporting)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                    .foregroundStyle(.secondary)
            }

            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope.circle")
            }

            Link(destination: URL(string: "https://asunnyboy861.github.io/ResumePoint-privacy/")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            Link(destination: URL(string: "https://asunnyboy861.github.io/ResumePoint-terms/")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
