import Foundation
import Observation
import SvertoCore

@Observable
final class CustomAssetsViewModel {
    private(set) var isLoading = true
    private(set) var assets: [AssetSummary] = []
    private(set) var assetTypes: [AssetTypeOption] = []
    private(set) var lastError: AssetErrorEvent?
    private(set) var loadError: String?

    private let store: AppStore

    init(store: AppStore) {
        self.store = store
    }

    func load() async {
        loadError = nil
        if assets.isEmpty {
            isLoading = true
        }
        do {
            async let loadedAssets = store.getUserAssets()
            if assetTypes.isEmpty {
                async let loadedTypes = store.getAssetTypes()
                let (fetchedAssets, fetchedTypes) = try await (loadedAssets, loadedTypes)
                assets = fetchedAssets
                assetTypes = fetchedTypes
            } else {
                assets = try await loadedAssets
            }
            isLoading = false
        } catch {
            isLoading = false
            loadError = error.friendlyMessage
            report(error)
        }
    }

    func createAsset(name: String, ticker: String, assetType: Int32, baseAssetId: Int32) async throws {
        _ = try await store.createUserAsset(name: name, ticker: ticker, assetType: assetType, baseAssetId: baseAssetId)
        await load()
    }

    func deleteAsset(id: Int32) async {
        do {
            try await store.deleteUserAsset(assetId: id)
            await load()
        } catch {
            report(error)
        }
    }

    private func report(_ error: Error) {
        lastError = AssetErrorEvent(error)
    }
}
