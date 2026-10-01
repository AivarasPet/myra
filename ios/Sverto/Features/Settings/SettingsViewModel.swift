import Foundation
import Observation
import SvertoCore

@Observable
final class SettingsViewModel {
    private(set) var baseCurrencyId: Int32?
    private(set) var baseCurrencyTicker: String?
    private(set) var databaseUsername: String?

    private let store: AppStore

    init(store: AppStore) {
        self.store = store
    }

    func load() async {
        let store = self.store
        let cachedMe = await Task.detached { store.getCachedMe() }.value
        databaseUsername = cachedMe?.userMetadata?.username
        baseCurrencyId = cachedMe?.defaultAsset?.id
        baseCurrencyTicker = cachedMe?.defaultAsset?.ticker
        await resolveBaseCurrencyTicker()
    }

    private func resolveBaseCurrencyTicker() async {
        guard let id = baseCurrencyId, let currencies = try? await store.getAllCurrencies() else { return }
        if let match = currencies.first(where: { $0.id == id }) {
            baseCurrencyTicker = match.ticker
        }
    }

    func selectBaseCurrency(_ asset: AssetItem) async throws {
        baseCurrencyId = asset.id
        baseCurrencyTicker = asset.ticker
        try await store.updateBaseAsset(assetId: asset.id, ticker: asset.ticker)
    }

    func displayName(authMode: AuthMode, clerkName: String?) -> String {
        switch authMode {
        case .clerk: clerkName ?? "Your account"
        case .database: databaseUsername ?? "Your account"
        case .noauth: "Local account"
        }
    }
}
