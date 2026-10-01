import MarkdownUI
import SvertoCore
import SwiftUI

struct ChatMessageBubble: View {
    let message: ChatMessage
    let isStreaming: Bool
    let isLastMessage: Bool

    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
            ForEach(Array(message.parts.enumerated()), id: \.offset) { index, part in
                switch part {
                case let .text(content):
                    if message.isUser {
                        UserTextBubble(content: content)
                    } else {
                        AssistantText(content: content, isStreaming: isStreaming && isLastMessage && index == message.parts.count - 1)
                    }
                case let .reasoning(content):
                    ReasoningCard(content: content, isStreaming: isStreaming && isLastMessage)
                case .toolCall:
                    if let tool = part.toolCall {
                        ToolCallCard(tool: tool)
                    }
                case let .file(_, mediaType, url):
                    AttachmentThumbnail(url: url, mediaType: mediaType)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}

private struct UserTextBubble: View {
    let content: String

    var body: some View {
        Text(content)
            .font(.body)
            .foregroundStyle(.white)
            .textSelection(.enabled)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(ChatBubbleShape.userFill, in: ChatBubbleShape.user)
            .frame(maxWidth: ChatBubbleShape.maxUserBubbleWidth, alignment: .trailing)
    }
}

private struct AssistantText: View {
    let content: String
    let isStreaming: Bool

    var body: some View {
        Group {
            if isStreaming {
                HStack(alignment: .bottom, spacing: 0) {
                    Text(content)
                        .font(.body)
                    StreamingCaret()
                }
            } else {
                Markdown(content)
                    .markdownTheme(.chat)
            }
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
    }
}
