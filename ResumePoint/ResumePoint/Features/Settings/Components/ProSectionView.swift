import SwiftUI

struct ProSectionView: View {
    @State private var showingPaywall = false

    var body: some View {
        Section {
            ProSectionContent(showingPaywall: $showingPaywall)
        } header: {
            Text("Pro Features")
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

struct ProSectionContent: View {
    @Binding var showingPaywall: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProHeaderRow(showingPaywall: $showingPaywall)

            Text("Unlock all features")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProFeaturePreviewList()
        }
        .padding(.vertical, 8)
    }
}

struct ProHeaderRow: View {
    @Binding var showingPaywall: Bool

    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundStyle(.yellow)
            Text("ResumePoint Pro")
                .font(.headline)
            Spacer()
            Button("Upgrade") {
                showingPaywall = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
        }
    }
}

struct ProFeaturePreviewList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(ProFeature.allCases.prefix(3)), id: \.self) { feature in
                ProFeaturePreviewRow(feature: feature)
            }
        }
    }
}

struct ProFeaturePreviewRow: View {
    let feature: ProFeature

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: feature.icon)
                .font(.caption)
                .foregroundStyle(.green)
            Text(feature.displayName)
                .font(.subheadline)
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PaywallHeader()

                    PaywallFeatureList()

                    PaywallPurchaseOptions()

                    Text("Restore Purchases")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct PaywallHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("Upgrade to Pro")
                .font(.title.weight(.bold))

            Text("Unlock all features and get the most out of ResumePoint")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct PaywallFeatureList: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(ProFeature.allCases) { feature in
                PaywallFeatureRow(feature: feature)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.compactCornerRadius))
        .padding(.horizontal)
    }
}

struct PaywallFeatureRow: View {
    let feature: ProFeature

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.displayName)
                    .font(.headline)
                Text(feature.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}

struct PaywallPurchaseOptions: View {
    var body: some View {
        VStack(spacing: 12) {
            SubscribeButton()

            OneTimePurchaseButton()
        }
        .padding(.horizontal)
    }
}

struct SubscribeButton: View {
    var body: some View {
        Button(action: {}) {
            Text("Subscribe - $2.99/month")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.compactCornerRadius))
        }
    }
}

struct OneTimePurchaseButton: View {
    var body: some View {
        Button(action: {}) {
            Text("One-time Purchase - $19.99")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.compactCornerRadius))
        }
    }
}

#Preview {
    ProSectionView()
}
