import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    @State private var isAppeared = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
                .scaleEffect(isAppeared ? 1.0 : 0.5)
                .opacity(isAppeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: isAppeared)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 10)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: isAppeared)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 10)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: isAppeared)
            }

            if let actionTitle, let action {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
                .scaleEffect(isAppeared ? 1.0 : 0.8)
                .opacity(isAppeared ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.4), value: isAppeared)
            }
        }
        .padding(40)
        .onAppear { isAppeared = true }
    }
}
