import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var isCompleted = false

    let pages: [OnboardingPage] = OnboardingPage.defaultPages

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var currentPageData: OnboardingPage {
        pages[currentPage]
    }

    func nextPage() {
        if isLastPage {
            complete()
        } else {
            withAnimation(.spring(response: 0.3)) {
                currentPage += 1
            }
        }
    }

    func skip() {
        complete()
    }

    private func complete() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isCompleted = true
        }
    }
}
