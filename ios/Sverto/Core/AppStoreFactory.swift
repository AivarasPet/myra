import Foundation
import SvertoCore

enum AppStoreFactory {
    static let cacheTTLSeconds: UInt64 = 60

    static func make(environment: AppEnvironment, authProvider: AuthProvider, credentialStore: CredentialStore) -> AppStore {
        AppStore(
            baseUrl: environment.apiBaseURL.absoluteString,
            cacheTtlSecs: cacheTTLSeconds,
            dbPath: databasePath(),
            authProvider: authProvider,
            credentialStore: credentialStore
        )
    }

    private static func databasePath() -> String {
        let fileManager = FileManager.default
        let directory = (try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            ?? fileManager.temporaryDirectory
        return directory.appendingPathComponent("sverto_cache.db").path
    }
}
