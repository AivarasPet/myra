import Foundation

struct AppEnvironment: Sendable {
    enum Flavor: String, Sendable {
        case dev
        case prod
    }

    let flavor: Flavor
    let apiBaseURL: URL
    let clerkPublishableKey: String

    var isClerkConfigured: Bool { !clerkPublishableKey.isEmpty }

    static let current: AppEnvironment = {
        let info = Bundle.main.infoDictionary ?? [:]
        let flavor = Flavor(rawValue: info["SvertoAppEnv"] as? String ?? "") ?? .prod
        let rawURL = (info["SvertoApiBaseUrl"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let url = URL(string: rawURL) ?? URL(string: "https://api.sverto.com")!
        let clerkKey = (info["SvertoClerkPublishableKey"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return AppEnvironment(flavor: flavor, apiBaseURL: url, clerkPublishableKey: clerkKey)
    }()
}
