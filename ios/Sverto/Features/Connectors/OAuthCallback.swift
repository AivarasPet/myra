import Foundation

struct OAuthCallback: Equatable {
    let state: String
    let code: String?
    let error: String?

    nonisolated init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        let query = { (name: String) in components.queryItems?.first { $0.name == name }?.value }
        guard let state = query("state") else { return nil }
        self.state = state
        code = query("code")
        error = query("error")
    }
}
