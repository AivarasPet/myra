import Foundation
import Observation
import SvertoCore

@Observable
final class ConnectionStatusModel {
    private(set) var status: ConnectionStatus = .online
    private let store: AppStore
    private var bridge: ConnectionObserverBridge?

    init(store: AppStore) {
        self.store = store
    }

    var bannerText: String? {
        switch status {
        case .online: nil
        case .deviceOffline: "You're offline"
        case .serverUnreachable: "Can't reach Sverto"
        }
    }

    func start() {
        guard bridge == nil else { return }
        let bridge = ConnectionObserverBridge { [weak self] status in
            Task { @MainActor [weak self] in self?.status = status }
        }
        self.bridge = bridge
        let store = self.store
        Task.detached { store.observeConnection(observer: bridge) }
    }

    func stop() {
        bridge = nil
        let store = self.store
        Task.detached { store.unobserveConnection() }
    }
}
