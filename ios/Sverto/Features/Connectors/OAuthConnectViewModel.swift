import Foundation
import Observation
import SvertoCore

@Observable
class OAuthConnectViewModel {
    private(set) var phase: OAuthConnectPhase = .idle
    private(set) var launchUrl: String?
    private(set) var connectionId: String?
    private(set) var error: String?

    let store: AppStore
    let kind: ConnectorKind

    init(store: AppStore, kind: ConnectorKind) {
        self.store = store
        self.kind = kind
    }

    var bankName: String? { nil }
    var bankCountry: String? { nil }

    var phaseMessage: String? {
        switch phase {
        case .denied: "Access was denied at the bank. You can try again."
        case .failed: error ?? "Something went wrong. Try again."
        case .idle, .working, .completed: nil
        }
    }

    func begin() async {
        phase = .working
        error = nil
        do {
            let connectionId = try await store.createConnectorConnection(
                input: CreateConnectionInput(providerKind: kind.rawValue, credentialMode: .stored, credential: nil, providerKeyId: nil)
            )
            let session = try await store.createConnectorOauthSession(
                connectionId: connectionId,
                bankName: bankName,
                bankCountry: bankCountry
            )
            phase = .idle
            launchUrl = session.authUrl
            self.connectionId = connectionId
        } catch {
            fail(error.friendlyMessage)
        }
    }

    func consumeLaunchUrl() {
        launchUrl = nil
    }

    func consumeCompleted() {
        phase = .idle
    }

    func fail(_ message: String) {
        phase = .failed
        error = message
    }

    func complete(state: String, code: String?, error: String?) async {
        guard phase != .working, phase != .completed else { return }
        phase = .working
        self.error = nil
        do {
            let result = try await store.completeConnectorOauthSession(state: state, code: code, error: error)
            phase = result.status == .completed ? .completed : .denied
            connectionId = result.connection.id
        } catch {
            fail(error.friendlyMessage)
        }
    }
}
