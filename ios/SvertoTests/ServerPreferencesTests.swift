import Foundation
import SvertoCore
import Testing
@testable import Sverto

private func withIsolatedDefaults(_ body: (UserDefaults) throws -> Void) throws {
    let suiteName = "SvertoTests.ServerPreferences.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }
    try body(defaults)
}

struct ServerPreferencesTests {
    @Test func freshStoreHasNoServerNoWelcomeFlagAndNoLastUrl() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)

            #expect(preferences.activeServer == nil)
            #expect(preferences.welcomeRequired == nil)
            #expect(preferences.lastSelfHostedUrl == nil)
        }
    }

    @Test func setActiveServerRoundTripsEveryFieldAndClearsWelcome() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)

            preferences.setActiveServer(url: "https://api.sverto.com", authMode: .clerk, origin: .hosted, version: "1.4.0")

            #expect(preferences.activeServer == ServerSelection(url: "https://api.sverto.com", authMode: .clerk, origin: .hosted, version: "1.4.0"))
            #expect(preferences.welcomeRequired == false)
        }
    }

    @Test func selfHostedDatabaseServerRoundTrips() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)

            preferences.setActiveServer(url: "http://192.168.1.10:3000", authMode: .database, origin: .selfHosted, version: "")

            #expect(preferences.activeServer == ServerSelection(url: "http://192.168.1.10:3000", authMode: .database, origin: .selfHosted, version: ""))
        }
    }

    @Test func clearActiveServerRemovesSelectionAndRequiresWelcome() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)
            preferences.setActiveServer(url: "https://api.sverto.com", authMode: .noauth, origin: .hosted, version: "1")

            preferences.clearActiveServer()

            #expect(preferences.activeServer == nil)
            #expect(preferences.welcomeRequired == true)
            #expect(defaults.object(forKey: "active_server_url") == nil)
            #expect(defaults.object(forKey: "active_auth_mode") == nil)
            #expect(defaults.object(forKey: "active_server_origin") == nil)
            #expect(defaults.object(forKey: "active_server_version") == nil)
        }
    }

    @Test func clearActiveServerKeepsLastSelfHostedUrl() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)
            preferences.setLastSelfHostedUrl("http://localhost:8080")
            preferences.setActiveServer(url: "http://localhost:8080", authMode: .noauth, origin: .selfHosted, version: "")

            preferences.clearActiveServer()

            #expect(preferences.lastSelfHostedUrl == "http://localhost:8080")
        }
    }

    @Test func lastSelfHostedUrlIsOverwrittenBySubsequentWrites() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)

            preferences.setLastSelfHostedUrl("http://one.local")
            preferences.setLastSelfHostedUrl("http://two.local")

            #expect(preferences.lastSelfHostedUrl == "http://two.local")
        }
    }

    @Test func usesAndroidCompatibleStorageKeys() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)

            preferences.setActiveServer(url: "https://api.sverto.com", authMode: .database, origin: .selfHosted, version: "2.0")
            preferences.setLastSelfHostedUrl("http://self.local")

            #expect(defaults.string(forKey: "active_server_url") == "https://api.sverto.com")
            #expect(defaults.string(forKey: "active_auth_mode") == "database")
            #expect(defaults.string(forKey: "active_server_origin") == "self_hosted")
            #expect(defaults.string(forKey: "active_server_version") == "2.0")
            #expect(defaults.string(forKey: "last_self_hosted_url") == "http://self.local")
            #expect(defaults.bool(forKey: "welcome_required") == false)
        }
    }

    @Test func unknownStoredAuthModeYieldsNoActiveServer() throws {
        try withIsolatedDefaults { defaults in
            defaults.set("https://api.sverto.com", forKey: "active_server_url")
            defaults.set("oauth", forKey: "active_auth_mode")

            #expect(ServerPreferences(defaults: defaults).activeServer == nil)
        }
    }

    @Test func missingAuthModeYieldsNoActiveServer() throws {
        try withIsolatedDefaults { defaults in
            defaults.set("https://api.sverto.com", forKey: "active_server_url")

            #expect(ServerPreferences(defaults: defaults).activeServer == nil)
        }
    }

    @Test func missingOrUnknownOriginIsReadAsNilAndMissingVersionAsEmpty() throws {
        try withIsolatedDefaults { defaults in
            defaults.set("https://api.sverto.com", forKey: "active_server_url")
            defaults.set("clerk", forKey: "active_auth_mode")

            let withoutOrigin = ServerPreferences(defaults: defaults).activeServer
            #expect(withoutOrigin == ServerSelection(url: "https://api.sverto.com", authMode: .clerk, origin: nil, version: ""))

            defaults.set("cloud", forKey: "active_server_origin")
            #expect(ServerPreferences(defaults: defaults).activeServer?.origin == nil)
        }
    }

    @Test func welcomeRequiredReflectsStoredBoolean() throws {
        try withIsolatedDefaults { defaults in
            let preferences = ServerPreferences(defaults: defaults)

            defaults.set(true, forKey: "welcome_required")
            #expect(preferences.welcomeRequired == true)

            defaults.set(false, forKey: "welcome_required")
            #expect(preferences.welcomeRequired == false)
        }
    }

    @Test func serverOriginRawValuesMatchAndroid() {
        #expect(ServerOrigin.hosted.rawValue == "hosted")
        #expect(ServerOrigin.selfHosted.rawValue == "self_hosted")
        #expect(ServerOrigin(rawValue: "self_hosted") == .selfHosted)
        #expect(ServerOrigin(rawValue: "selfHosted") == nil)
    }
}

struct AuthModeStorageTests {
    private let allModes: [AuthMode] = [.clerk, .database, .noauth]

    @Test func storageValuesAreLowercaseIdentifiers() {
        #expect(AuthMode.clerk.storageValue == "clerk")
        #expect(AuthMode.database.storageValue == "database")
        #expect(AuthMode.noauth.storageValue == "noauth")
    }

    @Test func storageValueRoundTripsForEveryMode() {
        for mode in allModes {
            #expect(AuthMode(storageValue: mode.storageValue) == mode)
        }
    }

    @Test func storageValuesAreUnique() {
        #expect(Set(allModes.map(\.storageValue)).count == allModes.count)
    }

    @Test func unknownStorageValueIsRejected() {
        #expect(AuthMode(storageValue: "") == nil)
        #expect(AuthMode(storageValue: "Clerk") == nil)
        #expect(AuthMode(storageValue: "password") == nil)
    }

    @Test func displayLabelsAreHumanReadable() {
        #expect(AuthMode.clerk.displayLabel == "Clerk")
        #expect(AuthMode.database.displayLabel == "Username and password")
        #expect(AuthMode.noauth.displayLabel == "No sign-in")
    }
}

struct PlausibleServerUrlTests {
    @Test func acceptsHttpAndHttpsUrlsWithHosts() {
        #expect(SessionCoordinator.isPlausibleServerUrl("https://api.sverto.com"))
        #expect(SessionCoordinator.isPlausibleServerUrl("http://localhost:8080"))
        #expect(SessionCoordinator.isPlausibleServerUrl("http://192.168.1.10:3000/api"))
        #expect(SessionCoordinator.isPlausibleServerUrl("https://sverto.example.com/base/path?x=1"))
    }

    @Test func schemeIsCaseInsensitive() {
        #expect(SessionCoordinator.isPlausibleServerUrl("HTTPS://API.SVERTO.COM"))
        #expect(SessionCoordinator.isPlausibleServerUrl("Http://localhost"))
    }

    @Test func surroundingWhitespaceIsIgnored() {
        #expect(SessionCoordinator.isPlausibleServerUrl("  https://api.sverto.com  "))
        #expect(SessionCoordinator.isPlausibleServerUrl("\nhttp://localhost:8080\n"))
    }

    @Test func rejectsMissingScheme() {
        #expect(!SessionCoordinator.isPlausibleServerUrl("api.sverto.com"))
        #expect(!SessionCoordinator.isPlausibleServerUrl("localhost:8080"))
        #expect(!SessionCoordinator.isPlausibleServerUrl("//api.sverto.com"))
    }

    @Test func rejectsNonHttpSchemes() {
        #expect(!SessionCoordinator.isPlausibleServerUrl("ftp://api.sverto.com"))
        #expect(!SessionCoordinator.isPlausibleServerUrl("sverto://connectors"))
        #expect(!SessionCoordinator.isPlausibleServerUrl("file:///etc/hosts"))
    }

    @Test func rejectsMissingHost() {
        #expect(!SessionCoordinator.isPlausibleServerUrl("https://"))
        #expect(!SessionCoordinator.isPlausibleServerUrl("https:///path"))
        #expect(!SessionCoordinator.isPlausibleServerUrl("http:"))
    }

    @Test func rejectsBlankAndGarbage() {
        #expect(!SessionCoordinator.isPlausibleServerUrl(""))
        #expect(!SessionCoordinator.isPlausibleServerUrl("   "))
        #expect(!SessionCoordinator.isPlausibleServerUrl("not a url"))
    }
}
