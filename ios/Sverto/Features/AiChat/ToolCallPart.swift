import Foundation
import SvertoCore

struct ToolCallPart: Hashable {
    var callId: String
    var name: String
    var params: String
    var state: ToolCallState
    var output: String?

    var messagePart: MessagePart {
        .toolCall(callId: callId, name: name, params: params, state: state.rawValue, output: output)
    }

    var isAwaitingApproval: Bool { state == .approvalRequested }
}

extension MessagePart {
    var toolCall: ToolCallPart? {
        guard case let .toolCall(callId, name, params, state, output) = self else { return nil }
        return ToolCallPart(
            callId: callId,
            name: name,
            params: params,
            state: ToolCallState(rawValue: state) ?? .inputAvailable,
            output: output
        )
    }

    var textContent: String? {
        guard case let .text(content) = self else { return nil }
        return content
    }

    var reasoningContent: String? {
        guard case let .reasoning(content) = self else { return nil }
        return content
    }
}

extension ChatMessage {
    var isUser: Bool { role == "user" }
    var isAssistant: Bool { role == "assistant" }

    var pendingApproval: ToolCallPart? {
        parts.compactMap(\.toolCall).first(where: \.isAwaitingApproval)
    }
}
