import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showingAddProgress = false
    @State private var selectedVideo: VideoProgress?

    private let storageService: ProgressStoring

    init(storageService: ProgressStoring) {
        self.storageService = storageService
        _viewModel = StateObject(wrappedValue: HomeViewModel(storageService: storageService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.videos.isEmpty {
                    EmptyStateView(
                        icon: "play.rectangle",
                        title: "No Videos Yet",
                        subtitle: "Start tracking your streaming progress by adding a video",
                        actionTitle: "Add Video",
                        action: { showingAddProgress = true }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ContinueWatchingSection(
                                videos: viewModel.videos,
                                onTap: { video in selectedVideo = video }
                            )
                            .padding(.top, 8)

                            ProgressList(
                                videos: viewModel.inProgressVideos,
                                onTap: { video in selectedVideo = video },
                                onDelete: { video in
                                    Task { await viewModel.deleteVideo(video) }
                                }
                            )
                            .frame(maxWidth: 700)
                            .frame(height: estimatedListHeight)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Search videos...")
                }
            }
            .navigationTitle("ResumePoint")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddProgress = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddProgress) {
                AddProgressView(storageService: storageService)
            }
            .sheet(item: $selectedVideo) { video in
                DetailView(video: video, storageService: storageService)
            }
            .task {
                await viewModel.loadVideos()
            }
            .refreshable {
                await viewModel.loadVideos()
            }
        }
    }

    private var estimatedListHeight: CGFloat {
        let count = viewModel.inProgressVideos.count
        return CGFloat(count) * 110
    }
}
