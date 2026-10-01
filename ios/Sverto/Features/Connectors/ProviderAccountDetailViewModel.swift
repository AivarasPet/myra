import Foundation
import Observation
import SvertoCore

@Observable
final class ProviderAccountDetailViewModel {
    private(set) var transactions: [ProviderAccountTransaction] = []
    private(set) var svertoAccounts: [AccountListItem] = []
    private(set) var linkedTo: String?
    private(set) var loading = true
    private(set) var justLinked = false
    private(set) var error: String?

    private let store: AppStore
    private let connectionId: String
    private let providerAccountId: String

    init(store: AppStore, connectionId: String, providerAccountId: String) {
        self.store = store
        self.connectionId = connectionId
        self.providerAccountId = providerAccountId
    }

    func load() async {
        loading = true
        error = nil
        do {
            let transactions = try await store.listConnectorProviderAccountTransactions(
                connectionId: connectionId,
                providerAccountId: providerAccountId
            )
            let linked = try await store.listConnectorBindings()
                .first { $0.connectionId == connectionId && $0.providerAccountId == providerAccountId }?
                .svertoAccountName
            let accounts = try await store.listSvertoAccounts()
            self.transactions = transactions
            svertoAccounts = accounts
            linkedTo = linked
            loading = false
        } catch {
            loading = false
            self.error = error.friendlyMessage
        }
    }

    func bind(svertoAccountId: String) async -> Bool {
        error = nil
        do {
            _ = try await store.createConnectorBinding(
                connectionId: connectionId,
                svertoAccountId: svertoAccountId,
                providerAccountId: providerAccountId
            )
            justLinked = true
            return true
        } catch {
            self.error = error.friendlyMessage
            return false
        }
    }
}
