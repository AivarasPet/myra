import Foundation
import Observation
import SvertoCore

@Observable
final class BindingSetupViewModel {
    private(set) var providerAccounts: [ProviderAccount] = []
    private(set) var boundAccounts: [String: String] = [:]
    private(set) var svertoAccounts: [AccountListItem] = []
    private(set) var loading = true
    private(set) var error: String?
    private(set) var loadError: String?

    private let store: AppStore
    private let connectionId: String

    init(store: AppStore, connectionId: String) {
        self.store = store
        self.connectionId = connectionId
    }

    func load() async {
        loading = true
        error = nil
        loadError = nil
        do {
            let provider = try await store.listConnectorProviderAccounts(connectionId: connectionId)
            let bound = try await store.listConnectorBindings()
                .filter { $0.connectionId == connectionId }
                .map { ($0.providerAccountId, $0.svertoAccountName) }
            let accounts = try await store.listSvertoAccounts()
            providerAccounts = provider
            boundAccounts = Dictionary(bound, uniquingKeysWith: { _, last in last })
            svertoAccounts = accounts
            loading = false
        } catch {
            loading = false
            loadError = "Couldn't load provider accounts. Pull down to try again."
        }
    }

    func bind(providerAccountId: String, svertoAccountId: String) async {
        error = nil
        do {
            _ = try await store.createConnectorBinding(
                connectionId: connectionId,
                svertoAccountId: svertoAccountId,
                providerAccountId: providerAccountId
            )
            await load()
        } catch {
            self.error = error.friendlyMessage
        }
    }
}
