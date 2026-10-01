import SwiftUI

enum DeepLinkAction: Hashable {
    case presentSettings([AppRoute])
    case selectTab(AppTab)
}

enum DeepLink {
    static let scheme = "sverto"

    static func route(for url: URL) -> DeepLinkAction? {
        guard url.scheme?.lowercased() == scheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        let host = components.host?.lowercased() ?? ""
        let path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
        let query = { (name: String) in components.queryItems?.first { $0.name == name }?.value }
        switch host {
        case "connectors":
            guard let kind = ConnectorKind(rawValue: path) else { return nil }
            switch kind {
            case .trueLayer:
                return .presentSettings([.connectors, .connectTrueLayer(code: query("code"), state: query("state"), error: query("error"))])
            case .enableBanking:
                return .presentSettings([.connectors, .connectEnableBanking(code: query("code"), state: query("state"), error: query("error"))])
            case .trading212:
                return nil
            }
        case "quick-upload" where path.isEmpty:
            return .selectTab(.transactions)
        default:
            return nil
        }
    }
}

extension View {
    func handlesSvertoDeepLinks() -> some View {
        modifier(DeepLinkHandling())
    }
}

private struct DeepLinkHandling: ViewModifier {
    @Environment(ShellState.self) private var shell

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                guard let action = DeepLink.route(for: url) else { return }
                perform(action)
            }
            .task { consumePendingOAuthReturn() }
    }

    private func perform(_ action: DeepLinkAction) {
        switch action {
        case let .presentSettings(path):
            shell.presentSettings(path)
        case let .selectTab(tab):
            shell.selectedTab = tab
        }
    }

    private func consumePendingOAuthReturn() {
        guard let route = shell.pendingOAuthReturn else { return }
        shell.pendingOAuthReturn = nil
        shell.presentSettings([.connectors, route])
    }
}
