import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            skipButton
            pageContent
            bottomControls
        }
        .background(Color(.systemBackground))
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                dismiss()
            }
        }
    }

    private var skipButton: some View {
        HStack {
            Spacer()
            Button("Skip") {
                viewModel.skip()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .padding()
        }
    }

    private var pageContent: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                OnboardingPageView(page: page)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var bottomControls: some View {
        VStack(spacing: Constants.UI.standardPadding) {
            OnboardingProgressDots(
                total: viewModel.pages.count,
                current: viewModel.currentPage
            )

            Button(action: { viewModel.nextPage() }) {
                Text(viewModel.isLastPage ? "Get Started" : "Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.currentPageData.color)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.UI.compactCornerRadius))
            }
            .padding(.horizontal, Constants.UI.standardPadding)
        }
        .padding(.bottom, Constants.UI.standardPadding * 2)
    }
}

#Preview {
    OnboardingView()
}
