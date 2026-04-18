import SwiftUI

struct ProgressList: View {
    let videos: [VideoProgress]
    var onTap: ((VideoProgress) -> Void)?
    var onDelete: ((VideoProgress) -> Void)?

    var body: some View {
        List {
            ForEach(videos) { video in
                ProgressCard(video: video) {
                    onTap?(video)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDelete?(video)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
