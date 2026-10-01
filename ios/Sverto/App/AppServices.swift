import Foundation
import Observation
import SvertoCore

@Observable
final class AppServices {
    let environment: AppEnvironment
    let store: AppStore
    let shell = ShellState()
    let connectivity: ConnectivityMonitor
    let connection: ConnectionStatusModel
    let clerk: ClerkGateway

    init(environment: AppEnvironment, store: AppStore, connectivity: ConnectivityMonitor, clerk: ClerkGateway) {
        self.environment = environment
        self.store = store
        self.connectivity = connectivity
        self.clerk = clerk
        connection = ConnectionStatusModel(store: store)
    }
}
