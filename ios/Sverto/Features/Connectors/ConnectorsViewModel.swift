import Foundation
import Observation
import SvertoCore

@Observable
final class ConnectorsViewModel {
    private(set) var connections: [ConnectorConnection] = []
    private(set) var loading = true
    private(set) var error: String?

    private let store: AppStore

    init(store: AppStore) {
        self.store = store
    }

    func load() async {
        loading = true
        error = nil
        do {
            connections = try await store.listConnectorConnections()
            loading = false
        } catch {
            loading = false
            self.error = error.friendlyMessage
        }
    }

    func activeCount(for kind: ConnectorKind) -> Int {
        connections.filter { $0.kind == kind && $0.connectionStatus == .active }.count
    }

    func connections(for kind: ConnectorKind) -> [ConnectorConnection] {
        connections.filter { $0.kind == kind }
    }
}
