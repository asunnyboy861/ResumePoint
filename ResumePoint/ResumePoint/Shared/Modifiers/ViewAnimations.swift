import SwiftUI

struct FadeInView: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    init(delay: Double = 0) {
        self.delay = delay
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .animation(.easeOut(duration: 0.4).delay(delay), value: isVisible)
            .onAppear { isVisible = true }
    }
}

struct ScaleOnTap: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false

    init(scale: CGFloat = 0.96) {
        self.scale = scale
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

struct SlideInFromRight: ViewModifier {
    let index: Int
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : 60)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: isVisible)
            .onAppear { isVisible = true }
    }
}

extension View {
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInView(delay: delay))
    }

    func scaleOnTap(scale: CGFloat = 0.96) -> some View {
        modifier(ScaleOnTap(scale: scale))
    }

    func slideInFromRight(index: Int) -> some View {
        modifier(SlideInFromRight(index: index))
    }
}
