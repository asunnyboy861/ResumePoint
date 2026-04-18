import SwiftUI

struct CardStyle: ViewModifier {
    let padding: CGFloat
    let cornerRadius: CGFloat

    init(
        padding: CGFloat = Constants.UI.standardPadding,
        cornerRadius: CGFloat = Constants.UI.compactCornerRadius
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle(
        padding: CGFloat = Constants.UI.standardPadding,
        cornerRadius: CGFloat = Constants.UI.compactCornerRadius
    ) -> some View {
        modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
    }
}
