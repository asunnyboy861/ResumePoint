import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var selectedVideo: VideoProgress?

    private let storageService: ProgressStoring

    init(storageService: ProgressStoring) {
        self.storageService = storageService
        _viewModel = StateObject(wrappedValue: SearchViewModel(storageService: storageService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                if viewModel.searchText.isEmpty {
                    recentSearchesSection
                } else if viewModel.isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if viewModel.results.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        subtitle: "Try a different search term"
                    )
                } else {
                    ProgressList(
                        videos: viewModel.results,
                        onTap: { video in selectedVideo = video },
                        onDelete: { video in
                            Task {
                                try? await storageService.deleteVideo(video)
                                await viewModel.search()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Search")
            .sheet(item: $selectedVideo) { video in
                DetailView(video: video, storageService: storageService)
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search videos...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .onSubmit {
                    Task { await viewModel.search() }
                }

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.clearSearch() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.compactCornerRadius))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var recentSearchesSection: some View {
        Group {
            if !viewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Recent Searches")
                            .font(.headline)
                        Spacer()
                        Button("Clear All") {
                            viewModel.recentSearches = []
                            UserDefaults.standard.removeObject(forKey: "recentSearches")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    ForEach(viewModel.recentSearches, id: \.self) { query in
                        Button(action: { viewModel.applyRecentSearch(query) }) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundStyle(.secondary)
                                Text(query)
                                Spacer()
                                Image(systemName: "xmark")
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top)
            } else {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "Search Videos",
                    subtitle: "Find your tracked videos by title"
                )
            }
        }
    }
}
