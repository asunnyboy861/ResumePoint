import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    let color: Color
    let height: CGFloat

    init(
        progress: Double,
        color: Color = .accentColor,
        height: CGFloat = 4
    ) {
        self.progress = min(max(progress, 0), 100)
        self.color = color
        self.height = height
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * (progress / 100), height: height)
                    .animation(.spring(response: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(progress: 25, color: .blue, height: 4)
        ProgressBarView(progress: 50, color: .green, height: 6)
        ProgressBarView(progress: 75, color: .orange, height: 8)
    }
    .padding()
}
