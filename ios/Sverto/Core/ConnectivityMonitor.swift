import Foundation
import Network
import SvertoCore

// NWPathMonitor → AppStore.setConnectivity; on reconnect also flushes queued receipt uploads,
// because the Rust side cannot spawn that work from a synchronous FFI call.
final class ConnectivityMonitor {
    private let store: AppStore
    private let probe: ConnectivityProbe
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.sverto.connectivity")
    private(set) var isConnected: Bool = true

    init(store: AppStore, probe: ConnectivityProbe) {
        self.store = store
        self.probe = probe
    }

    func start() {
        monitor.pathUpdateHandler = { path in
            let isSatisfied = path.status == .satisfied
            Task { @MainActor [weak self] in
                self?.apply(connected: isSatisfied)
            }
        }
        monitor.start(queue: queue)
    }

    func refreshAfterForeground() {
        guard isConnected else { return }
        let store = self.store
        Task.detached { await store.refreshQuickUploads() }
    }

    private func apply(connected isNowConnected: Bool) {
        let wasConnected = isConnected
        isConnected = isNowConnected
        probe.set(isNowConnected)
        store.setConnectivity(connected: isNowConnected)
        guard isNowConnected, !wasConnected else { return }
        let store = self.store
        Task.detached { await store.refreshQuickUploads() }
    }
}
