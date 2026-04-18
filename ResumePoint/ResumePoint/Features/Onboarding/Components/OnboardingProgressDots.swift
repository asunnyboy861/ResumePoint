import SwiftUI

struct OnboardingProgressDots: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}

#Preview {
    OnboardingProgressDots(total: 4, current: 1)
}
