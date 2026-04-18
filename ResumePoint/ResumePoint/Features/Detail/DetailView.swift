import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(video: VideoProgress, storageService: ProgressStoring) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(video: video, storageService: storageService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.standardPadding) {
                    heroSection
                    progressSection
                    detailsSection
                    notesSection
                    actionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ProgressRing(
                progress: viewModel.video.progressPercentage,
                lineWidth: 8,
                size: 120,
                color: Color(hex: viewModel.video.streamingPlatform.accentColor)
            )

            Text(viewModel.video.title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Image(systemName: viewModel.video.streamingPlatform.iconName)
                Text(viewModel.video.streamingPlatform.displayName)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .cardStyle(padding: 24)
    }

    private var progressSection: some View {
        HStack(spacing: Constants.UI.standardPadding) {
            VStack(spacing: 4) {
                Text(viewModel.video.formattedCurrentPosition)
                    .font(.title3.weight(.semibold))
                Text("Watched")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 40)

            VStack(spacing: 4) {
                Text(viewModel.video.formattedTotalDuration)
                    .font(.title3.weight(.semibold))
                Text("Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 40)

            VStack(spacing: 4) {
                Text(viewModel.video.remainingTime.formattedTime())
                    .font(.title3.weight(.semibold))
                Text("Remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .cardStyle()
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            detailRow(icon: "calendar", label: "Added", value: viewModel.video.createdAt.dateTimeString)
            detailRow(icon: "clock.arrow.circlepath", label: "Last Updated", value: viewModel.video.lastUpdated.dateTimeString)
            detailRow(icon: "percent", label: "Progress", value: "\(Int(viewModel.video.progressPercentage))%")

            if viewModel.video.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Completed")
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
            }
        }
        .cardStyle()
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Notes")
                    .font(.headline)

                Spacer()

                Button(viewModel.isEditing ? "Save" : "Edit") {
                    if viewModel.isEditing {
                        Task { await viewModel.saveNotes() }
                    } else {
                        viewModel.isEditing = true
                    }
                }
                .font(.subheadline)
            }

            if viewModel.isEditing {
                TextField("Add notes...", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(viewModel.notes.isEmpty ? "No notes yet" : viewModel.notes)
                    .font(.body)
                    .foregroundStyle(viewModel.notes.isEmpty ? .secondary : .primary)
            }
        }
        .cardStyle()
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if !viewModel.video.isCompleted {
                Button(action: {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    Task { await viewModel.markCompleted() }
                }) {
                    Label("Mark as Completed", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }

            Button(role: .destructive, action: {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                Task { await viewModel.deleteVideo(); dismiss() }
            }) {
                Label("Delete Progress", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .cardStyle()
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
