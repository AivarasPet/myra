import Foundation
import SvertoCore

enum ServerOrigin: String, Sendable {
    case hosted
    case selfHosted = "self_hosted"
}

struct ServerSelection: Equatable, Sendable {
    var url: String
    var authMode: AuthMode
    var origin: ServerOrigin?
    var version: String
}

struct ServerPreferences {
    private let defaults: UserDefaults

    private enum Key {
        static let activeServerUrl = "active_server_url"
        static let activeAuthMode = "active_auth_mode"
        static let activeServerOrigin = "active_server_origin"
        static let activeServerVersion = "active_server_version"
        static let lastSelfHostedUrl = "last_self_hosted_url"
        static let welcomeRequired = "welcome_required"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var activeServer: ServerSelection? {
        guard let url = defaults.string(forKey: Key.activeServerUrl),
              let modeRaw = defaults.string(forKey: Key.activeAuthMode),
              let mode = AuthMode(storageValue: modeRaw) else { return nil }
        let origin = defaults.string(forKey: Key.activeServerOrigin).flatMap(ServerOrigin.init(rawValue:))
        return ServerSelection(url: url, authMode: mode, origin: origin, version: defaults.string(forKey: Key.activeServerVersion) ?? "")
    }

    var lastSelfHostedUrl: String? {
        defaults.string(forKey: Key.lastSelfHostedUrl)
    }

    var welcomeRequired: Bool? {
        defaults.object(forKey: Key.welcomeRequired) == nil ? nil : defaults.bool(forKey: Key.welcomeRequired)
    }

    func setActiveServer(url: String, authMode: AuthMode, origin: ServerOrigin, version: String) {
        defaults.set(url, forKey: Key.activeServerUrl)
        defaults.set(authMode.storageValue, forKey: Key.activeAuthMode)
        defaults.set(origin.rawValue, forKey: Key.activeServerOrigin)
        defaults.set(version, forKey: Key.activeServerVersion)
        defaults.set(false, forKey: Key.welcomeRequired)
    }

    func clearActiveServer() {
        defaults.removeObject(forKey: Key.activeServerUrl)
        defaults.removeObject(forKey: Key.activeAuthMode)
        defaults.removeObject(forKey: Key.activeServerOrigin)
        defaults.removeObject(forKey: Key.activeServerVersion)
        defaults.set(true, forKey: Key.welcomeRequired)
    }

    func setLastSelfHostedUrl(_ url: String) {
        defaults.set(url, forKey: Key.lastSelfHostedUrl)
    }
}

extension AuthMode {
    var storageValue: String {
        switch self {
        case .clerk: "clerk"
        case .database: "database"
        case .noauth: "noauth"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "clerk": self = .clerk
        case "database": self = .database
        case "noauth": self = .noauth
        default: return nil
        }
    }

    var displayLabel: String {
        switch self {
        case .clerk: "Clerk"
        case .database: "Username and password"
        case .noauth: "No sign-in"
        }
    }
}
