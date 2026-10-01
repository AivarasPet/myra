import Foundation
import Observation
import SvertoCore

enum Trading212Mode: CaseIterable, Hashable {
    case stored
    case onDevice
    case client

    var label: String {
        switch self {
        case .stored: "Stored"
        case .onDevice: "On-device"
        case .client: "Client-driven"
        }
    }

    var credentialMode: CredentialMode? {
        switch self {
        case .stored: .stored
        case .onDevice: .transient
        case .client: nil
        }
    }

    var explanation: String {
        switch self {
        case .stored:
            "Your API key is encrypted and kept on Sverto's servers. Syncs can run in the background and work from all your devices."
        case .onDevice:
            "Your API key never leaves this device — it is kept in this app's local storage and sent only with each sync you trigger. Syncs run only while the app is open, and other devices need their own key."
        case .client:
            "Coming soon — your device fetches data from Trading 212 directly and uploads it to Sverto."
        }
    }
}

@Observable
final class ConnectTrading212ViewModel {
    private(set) var submitting = false
    private(set) var error: String?

    private let store: AppStore

    init(store: AppStore) {
        self.store = store
    }

    func connect(mode: CredentialMode, apiKeyId: String, apiKey: String) async -> String? {
        submitting = true
        error = nil
        defer { submitting = false }
        let trimmedKeyId = apiKeyId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let connectionId = try await store.createConnectorConnection(
                input: CreateConnectionInput(
                    providerKind: ConnectorKind.trading212.rawValue,
                    credentialMode: mode,
                    credential: mode == .stored ? trimmedKey : nil,
                    providerKeyId: trimmedKeyId.isEmpty ? nil : trimmedKeyId
                )
            )
            if mode == .transient {
                let store = self.store
                await Task.detached { store.saveConnectorCredential(connectionId: connectionId, secret: trimmedKey) }.value
            }
            return connectionId
        } catch {
            self.error = error.friendlyMessage
            return nil
        }
    }
}
