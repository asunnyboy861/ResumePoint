import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color

    init(
        progress: Double,
        lineWidth: CGFloat = 4,
        size: CGFloat = 44,
        color: Color = .blue
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress / 100, 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            Text("\(Int(progress))%")
                .font(.system(size: size * 0.28, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(width: size, height: size)
    }
}
