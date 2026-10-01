import Foundation
import Synchronization

// Thread-safe "are we online" flag shared between the NWPathMonitor owner, the Rust auth
// provider (called on Rust threads) and the session coordinator.
nonisolated final class ConnectivityProbe: Sendable {
    private let connected = Mutex<Bool>(true)

    var isConnected: @Sendable () -> Bool {
        { [self] in self.connected.withLock { $0 } }
    }

    func set(_ value: Bool) {
        connected.withLock { $0 = value }
    }
}
