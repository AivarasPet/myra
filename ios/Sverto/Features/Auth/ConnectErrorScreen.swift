import SwiftUI

struct ConnectErrorScreen: View {
    let message: String
    @Environment(SessionCoordinator.self) private var session

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't connect", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            VStack(spacing: 12) {
                Button("Retry") { session.retryHostedConnect() }
                    .buttonStyle(.borderedProminent)
                Button("Back") { session.showWelcome() }
                    .buttonStyle(.bordered)
            }
            .controlSize(.large)
        }
        .background(Color(.systemGroupedBackground))
    }
}
