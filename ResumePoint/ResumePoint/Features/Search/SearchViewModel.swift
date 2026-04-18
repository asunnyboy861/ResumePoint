import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [VideoProgress] = []
    @Published var recentSearches: [String] = []
    @Published var isSearching = false

    private let storageService: ProgressStoring

    init(storageService: ProgressStoring) {
        self.storageService = storageService
        loadRecentSearches()
    }

    func search() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        isSearching = true
        results = (try? await storageService.searchVideos(query: searchText)) ?? []
        isSearching = false
        addToRecentSearches(searchText)
    }

    func clearSearch() {
        searchText = ""
        results = []
    }

    func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        saveRecentSearches()
    }

    func applyRecentSearch(_ query: String) {
        searchText = query
        Task { await search() }
    }

    private func addToRecentSearches(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        recentSearches.removeAll { $0 == trimmed }
        recentSearches.insert(trimmed, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        saveRecentSearches()
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
}
