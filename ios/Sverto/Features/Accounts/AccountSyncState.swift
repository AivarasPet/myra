import Foundation
import SvertoCore

struct AccountSyncTarget: Equatable {
    let binding: ConnectorBinding
    let credentialMode: CredentialMode

    var isActive: Bool { binding.bindingStatus == .active }
}

struct AccountSyncPrompt: Identifiable, Equatable {
    let connectionId: String

    var id: String { connectionId }
}

struct AccountSyncState: Equatable {
    var targets: [AccountSyncTarget] = []
    var lastSyncAt: Int64?
    var isSyncing = false
    var message: String?
    var promptConnectionId: String?

    var canSync: Bool { !targets.isEmpty }
    var prompt: AccountSyncPrompt? { promptConnectionId.map(AccountSyncPrompt.init) }
}
