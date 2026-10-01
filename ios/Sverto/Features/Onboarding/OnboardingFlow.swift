import SwiftUI

struct OnboardingFlow: View {
    let onComplete: () -> Void

    @Environment(AppServices.self) private var services
    @State private var model: OnboardingViewModel?

    var body: some View {
        if let model {
            OnboardingPager(model: model, onComplete: onComplete)
        } else {
            LoadingScreen()
                .onAppear { model = OnboardingViewModel(store: services.store) }
        }
    }
}
