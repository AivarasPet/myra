import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.screenBackground)
    }
}

struct RetryErrorState: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(message, systemImage: "exclamationmark.triangle")
        } description: {
            Text("Check your connection and try again")
        } actions: {
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    VStack {
        LoadingScreen()
        RetryErrorState(message: "Couldn't load your portfolio") {}
    }
}
