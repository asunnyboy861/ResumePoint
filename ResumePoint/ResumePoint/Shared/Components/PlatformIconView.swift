import SwiftUI

struct PlatformIconView: View {
    let platform: StreamingPlatform
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .fill(platformColor.opacity(0.15))

            Image(systemName: platform.iconName)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(platformColor)
        }
        .frame(width: size, height: size)
    }

    private var platformColor: Color {
        Color(hex: platform.accentColor)
    }
}

#Preview {
    HStack(spacing: 16) {
        PlatformIconView(platform: .netflix)
        PlatformIconView(platform: .disneyplus)
        PlatformIconView(platform: .hbomax)
        PlatformIconView(platform: .primevideo)
        PlatformIconView(platform: .hulu)
        PlatformIconView(platform: .youtube)
    }
    .padding()
}
