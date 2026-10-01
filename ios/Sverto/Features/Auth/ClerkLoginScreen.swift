import ClerkKitUI
import SwiftUI

struct ClerkLoginScreen: View {
    @Environment(SessionCoordinator.self) private var session
    @Environment(ClerkGateway.self) private var clerk

    var body: some View {
        ZStack(alignment: .topLeading) {
            if !clerk.isConfigured {
                ContentUnavailableView(
                    "Sign-in unavailable",
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    description: Text("This build has no Clerk publishable key, but the server requires Clerk sign-in.")
                )
            } else if clerk.isLoaded {
                AuthView(isDismissible: false) {
                    session.onClerkSignedIn()
                }
            } else {
                LoadingScreen()
            }
            Button("Back", systemImage: "chevron.backward") {
                session.showWelcome()
            }
            .buttonStyle(.glass)
            .padding()
        }
    }
}
