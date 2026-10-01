import Foundation
import Observation
import SvertoCore

@Observable
final class ConnectionDetailViewModel {
    private(set) var connection: ConnectorConnection?
    private(set) var bindings: [ConnectorBinding] = []
    private(set) var providerAccountNames: [String: String] = [:]
    private(set) var loading = true
    private(set) var error: String?

    private let store: AppStore
    private let connectionId: String

    init(store: AppStore, connectionId: String) {
        self.store = store
        self.connectionId = connectionId
    }

    func load() async {
        loading = true
        error = nil
        do {
            let connection = try await store.listConnectorConnections().first { $0.id == connectionId }
            let bindings = try await store.listConnectorBindings().filter { $0.connectionId == connectionId }
            let accounts = (try? await store.listConnectorProviderAccounts(connectionId: connectionId)) ?? []
            self.connection = connection
            self.bindings = bindings
            providerAccountNames = Dictionary(accounts.map { ($0.providerAccountId, $0.displayName) }, uniquingKeysWith: { first, _ in first })
            loading = false
        } catch {
            loading = false
            self.error = error.friendlyMessage
        }
    }

    func rawAccountName(for binding: ConnectorBinding) -> String {
        providerAccountNames[binding.providerAccountId] ?? binding.providerAccountId
    }

    func updateBinding(_ binding: ConnectorBinding, writeMode: BindingWriteMode, status: BindingStatus) async {
        error = nil
        let previous = bindings
        bindings = previous.map { current in
            guard current.id == binding.id else { return current }
            var updated = current
            updated.writeMode = writeMode
            updated.status = status.connectorStatus.rawValue
            return updated
        }
        do {
            _ = try await store.updateConnectorBinding(bindingId: binding.id, writeMode: writeMode, status: status)
        } catch {
            bindings = previous
            self.error = error.friendlyMessage
        }
    }

    func deleteBinding(id: String) async {
        error = nil
        do {
            try await store.deleteConnectorBinding(bindingId: id)
            await load()
        } catch {
            self.error = error.friendlyMessage
        }
    }

    func revoke() async -> Bool {
        error = nil
        do {
            try await store.revokeConnectorConnection(connectionId: connectionId)
            return true
        } catch {
            self.error = error.friendlyMessage
            return false
        }
    }
}
