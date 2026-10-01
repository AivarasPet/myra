import SwiftUI

struct WelcomeScreen: View {
    @Environment(SessionCoordinator.self) private var session

    var body: some View {
        VStack(spacing: 0) {
            OnboardingPageIndicator(pageCount: OnboardingSteps.steps(forCompletedVersion: 0).count, currentPage: 0)
                .padding(.top, 24)
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 32) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 128, height: 128)
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                        VStack(spacing: 16) {
                            Text("Welcome to Sverto")
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                            Text("Your personal finance companion. Track accounts, manage investments, and let Myra AI help you make smarter decisions.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                }
            }
            VStack(spacing: 12) {
                ProminentActionButton(title: "Next") { session.continueWithHosted() }
                Button {
                    session.showServerUrlInput()
                } label: {
                    Text("Connect to self-hosted server")
                        .underline()
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .background {
            ZStack {
                Color(.systemBackground)
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.28), Color.accentColor.opacity(0)],
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.6)
                )
            }
            .ignoresSafeArea()
        }
    }
}
