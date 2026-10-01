import SwiftUI

extension ServerConnectionStatus {
    func scoped(to url: String) -> ServerConnectionStatus {
        switch self {
        case .idle:
            self
        case let .checking(statusUrl), let .found(statusUrl, _), let .error(statusUrl, _):
            statusUrl == url ? self : .idle
        }
    }

    var isChecking: Bool {
        if case .checking = self { return true }
        return false
    }

    var isFound: Bool {
        if case .found = self { return true }
        return false
    }

    var title: String {
        switch self {
        case .idle: "Connect your server"
        case .checking: "Looking for Sverto…"
        case .found: "Sverto server found"
        case .error: "Server not found"
        }
    }

    var description: String {
        switch self {
        case .idle: "Enter your self-hosted Sverto address. We'll verify it before connecting."
        case .checking: "Checking the address and reading its configuration."
        case .found: "This server is ready. Review the details and continue to sign in."
        case .error: "Sverto didn't respond at this address."
        }
    }

    var heroTint: Color {
        switch self {
        case .found: .green
        case .error: .red
        case .idle, .checking: .accentColor
        }
    }

    var heroSystemImage: String? {
        switch self {
        case .idle: "server.rack"
        case .found: "checkmark.seal.fill"
        case .error: "exclamationmark.triangle.fill"
        case .checking: nil
        }
    }

    var primaryButtonTitle: String {
        switch self {
        case .found: "Continue"
        case .checking: "Checking…"
        case .idle, .error: "Check server"
        }
    }
}
