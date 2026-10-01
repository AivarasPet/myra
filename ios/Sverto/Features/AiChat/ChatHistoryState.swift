import SvertoCore
import Synchronization

nonisolated enum ChatHistoryState: Equatable {
    case idle
    case loading
    case loaded
    case failed
}

nonisolated struct ChatHistoryRequest {
    let conversationId: String
    let generation: UInt
}

nonisolated final class ChatHistoryReceipt: Sendable {
    private struct Receipt {
        var conversationId: String?
        var messages: [ChatMessage]?
    }

    private let receipt = Mutex(Receipt())

    func begin(conversationId: String) {
        receipt.withLock { $0 = Receipt(conversationId: conversationId) }
    }

    func receive(conversationId: String, messages: [ChatMessage]) -> Bool {
        receipt.withLock {
            guard $0.conversationId == conversationId else { return false }
            $0.messages = messages
            return true
        }
    }

    func finish() -> [ChatMessage]? {
        receipt.withLock {
            let messages = $0.messages
            $0 = Receipt()
            return messages
        }
    }
}
