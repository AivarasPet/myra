import ClerkKitUI
import SwiftUI

struct ClerkLoginScreen: View {
    @Environment(SessionCoordinator.self) private var session
    @Environment(ClerkGateway.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if clerk.isConfigured && clerk.isLoaded {
            AuthView(isDismissible: false) {
                session.onClerkSignedIn()
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .accessibilityLabel("Close sign-in")
                .padding(.trailing, 16)
            }
        } else {
            NavigationStack {
                Group {
                    if !clerk.isConfigured {
                        ContentUnavailableView(
                            "Sign-in unavailable",
                            systemImage: "person.crop.circle.badge.exclamationmark",
                            description: Text("This build has no Clerk publishable key, but the server requires Clerk sign-in.")
                        )
                    } else {
                        LoadingScreen()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark") {
                            session.showWelcome()
                        }
                    }
                }
            }
        }
    }
}
