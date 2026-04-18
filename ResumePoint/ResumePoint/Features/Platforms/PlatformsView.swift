import SwiftUI

struct PlatformsView: View {
    @StateObject private var viewModel: PlatformsViewModel
    @State private var selectedVideo: VideoProgress?

    private let storageService: ProgressStoring

    init(storageService: ProgressStoring) {
        self.storageService = storageService
        _viewModel = StateObject(wrappedValue: PlatformsViewModel(storageService: storageService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.platforms.isEmpty {
                    EmptyStateView(
                        icon: "tv",
                        title: "No Platforms Yet",
                        subtitle: "Add videos to see them organized by streaming platform"
                    )
                } else if let selected = viewModel.selectedPlatform {
                    platformDetailView(selected)
                } else {
                    platformsList
                }
            }
            .navigationTitle("Platforms")
            .task {
                await viewModel.loadPlatforms()
            }
        }
    }

    private var platformsList: some View {
        List(viewModel.platforms, id: \.0.id) { platform, count in
            Button(action: {
                Task { await viewModel.selectPlatform(platform) }
            }) {
                HStack(spacing: Constants.UI.standardPadding) {
                    Image(systemName: platform.iconName)
                        .font(.title2)
                        .foregroundStyle(Color(hex: platform.accentColor))
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(platform.displayName)
                            .font(.headline)
                        Text("\(count) video\(count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func platformDetailView(_ platform: StreamingPlatform) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { viewModel.selectedPlatform = nil }) {
                    Image(systemName: "chevron.left")
                    Text("Platforms")
                }
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)

            if viewModel.videosForPlatform.isEmpty {
                EmptyStateView(
                    icon: "film",
                    title: "No Videos",
                    subtitle: "No videos found for \(platform.displayName)"
                )
            } else {
                ProgressList(
                    videos: viewModel.videosForPlatform,
                    onTap: { video in selectedVideo = video },
                    onDelete: { video in
                        Task {
                            try? await storageService.deleteVideo(video)
                            await viewModel.loadPlatforms()
                            if let selected = viewModel.selectedPlatform {
                                await viewModel.selectPlatform(selected)
                            }
                        }
                    }
                )
            }
        }
        .navigationTitle(platform.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedVideo) { video in
            DetailView(video: video, storageService: storageService)
        }
    }
}
