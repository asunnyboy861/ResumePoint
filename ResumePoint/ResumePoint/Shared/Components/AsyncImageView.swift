import SwiftUI

struct AsyncImageView: View {
    let urlString: String?
    let cornerRadius: CGFloat

    @State private var loadedImage: Image?
    @State private var isLoading = false

    init(urlString: String?, cornerRadius: CGFloat = Constants.UI.compactCornerRadius) {
        self.urlString = urlString
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            if let loadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .overlay {
                        Image(systemName: "film")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let urlString, loadedImage == nil, !isLoading else { return }
        isLoading = true

        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedImage = Image(uiImage: uiImage)
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}
