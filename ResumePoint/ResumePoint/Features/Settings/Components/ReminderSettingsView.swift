import SwiftUI

struct ReminderSettingsView: View {
    @ObservedObject var reminderService: SmartReminderService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Rules") {
                    ForEach(ReminderRule.allCases) { rule in
                        Toggle(isOn: Binding(
                            get: { reminderService.config.enabledRules.contains(rule) },
                            set: { enabled in
                                if enabled {
                                    reminderService.config.enabledRules.insert(rule)
                                } else {
                                    reminderService.config.enabledRules.remove(rule)
                                }
                                reminderService.updateConfig(reminderService.config)
                            }
                        )) {
                            Label(rule.displayName, systemImage: rule.icon)
                        }
                    }
                }

                Section("Timing") {
                    Stepper(
                        "Long time threshold: \(Int(reminderService.config.longTimeThreshold / 86400)) days",
                        value: Binding(
                            get: { reminderService.config.longTimeThreshold / 86400 },
                            set: {
                                reminderService.config.longTimeThreshold = $0 * 86400
                                reminderService.updateConfig(reminderService.config)
                            }
                        ),
                        in: 1...30
                    )

                    Stepper(
                        "Near completion: \(Int(reminderService.config.nearCompletionThreshold))%",
                        value: Binding(
                            get: { reminderService.config.nearCompletionThreshold },
                            set: {
                                reminderService.config.nearCompletionThreshold = $0
                                reminderService.updateConfig(reminderService.config)
                            }
                        ),
                        in: 50...99
                    )
                }

                Section("Quiet Hours") {
                    HStack {
                        Text("Start")
                        Spacer()
                        Text("\(reminderService.config.quietHoursStart):00")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("End")
                        Spacer()
                        Text("\(reminderService.config.quietHoursEnd):00")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Smart Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ReminderSettingsView(reminderService: SmartReminderService(notificationService: NotificationService()))
}
