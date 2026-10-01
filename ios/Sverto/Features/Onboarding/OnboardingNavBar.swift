import SwiftUI

struct OnboardingNavBar: View {
    let isFirstPage: Bool
    let isLastPage: Bool
    let isForwardEnabled: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onFinish: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if !isFirstPage {
                Button("Back", action: onBack)
                    .controlSize(.large)
                    .frame(minWidth: 44, minHeight: 44)
            }
            ProminentActionButton(title: isLastPage ? "Get started" : "Next", action: isLastPage ? onFinish : onNext)
                .disabled(!isForwardEnabled)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}
