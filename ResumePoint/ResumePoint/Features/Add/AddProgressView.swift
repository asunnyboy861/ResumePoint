import SwiftUI

struct AddProgressView: View {
    @StateObject private var viewModel: AddProgressViewModel
    @Environment(\.dismiss) private var dismiss

    init(storageService: ProgressStoring) {
        _viewModel = StateObject(wrappedValue: AddProgressViewModel(storageService: storageService))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Video Details") {
                    TextField("Title", text: $viewModel.title)

                    Picker("Platform", selection: $viewModel.selectedPlatform) {
                        ForEach(StreamingPlatform.allCases) { platform in
                            HStack {
                                Image(systemName: platform.iconName)
                                Text(platform.displayName)
                            }
                            .tag(platform)
                        }
                    }
                }

                Section("Current Position") {
                    HStack {
                        timePicker(value: $viewModel.currentPositionHours, label: "H", range: 0...23)
                        Text(":")
                        timePicker(value: $viewModel.currentPositionMinutes, label: "M", range: 0...59)
                        Text(":")
                        timePicker(value: $viewModel.currentPositionSeconds, label: "S", range: 0...59)
                    }
                }

                Section("Total Duration") {
                    HStack {
                        timePicker(value: $viewModel.totalDurationHours, label: "H", range: 0...23)
                        Text(":")
                        timePicker(value: $viewModel.totalDurationMinutes, label: "M", range: 0...59)
                        Text(":")
                        timePicker(value: $viewModel.totalDurationSeconds, label: "S", range: 0...59)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        Task {
                            if await viewModel.save() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func timePicker(value: Binding<Int>, label: String, range: ClosedRange<Int>) -> some View {
        VStack {
            Picker(label, selection: value) {
                ForEach(range, id: \.self) { num in
                    Text(String(format: "%02d", num)).tag(num)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 100)
            .clipped()
        }
    }
}
