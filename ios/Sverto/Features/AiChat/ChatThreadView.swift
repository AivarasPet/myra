import SvertoCore
import SwiftUI

struct ChatThreadView: View {
    let model: AiChatViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scrollState = ChatScrollState()

    private static let bottomAnchor = "bottom"

    private struct ScrollTrigger: Equatable {
        var conversationId: String?
        var userMessageCount: Int
        var messageCount: Int
        var lastTextLength: Int
        var isStreaming: Bool
        var hasPendingApproval: Bool
    }

    private var scrollTrigger: ScrollTrigger {
        ScrollTrigger(
            conversationId: model.activeConversationId,
            userMessageCount: model.messages.count(where: \.isUser),
            messageCount: model.messages.count,
            lastTextLength: model.messages.last?.parts.last?.textContent?.count ?? 0,
            isStreaming: model.isStreaming,
            hasPendingApproval: model.pendingApproval != nil
        )
    }

    private var isStreamingText: Bool {
        guard let last = model.messages.last, last.isAssistant else { return false }
        return last.parts.last?.textContent != nil
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(model.messages.enumerated()), id: \.offset) { index, message in
                        ChatMessageBubble(
                            message: message,
                            isStreaming: model.isStreaming,
                            isLastMessage: index == model.messages.count - 1
                        )
                    }
                    if model.isStreaming, !isStreamingText {
                        WorkingDots()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let pending = model.pendingApproval {
                        ToolApprovalCard(
                            toolName: pending.name,
                            params: pending.params,
                            onApprove: { model.approveTool(approved: true) },
                            onDeny: { model.approveTool(approved: false) }
                        )
                    }
                    Color.clear
                        .frame(height: 1)
                        .id(Self.bottomAnchor)
                }
                .padding(14)
                .animation(reduceMotion ? nil : .snappy, value: model.messages.count)
            }
            .defaultScrollAnchor(.bottom, for: .initialOffset)
            .defaultScrollAnchor(.bottom, for: .alignment)
            .scrollDismissesKeyboard(.interactively)
            .scrollEdgeEffectStyle(.hard, for: .bottom)
            .onScrollGeometryChange(for: Bool.self) { geometry in
                isAtBottom(geometry)
            } action: { _, isAtBottom in
                scrollState.geometryChanged(isAtBottom: isAtBottom)
                if scrollState.shouldFollowLatest, !isAtBottom {
                    scrollToLatest(proxy, animated: false)
                }
            }
            .onScrollPhaseChange { _, phase, context in
                let isUserScrolling = phase == .tracking || phase == .interacting || phase == .decelerating
                scrollState.phaseChanged(isUserScrolling: isUserScrolling, isAtBottom: isAtBottom(context.geometry))
                if phase == .idle, scrollState.shouldFollowLatest {
                    scrollToLatest(proxy, animated: false)
                }
            }
            .onChange(of: scrollTrigger) { previous, current in
                let changedConversation = previous.conversationId != current.conversationId
                let sentMessage = current.userMessageCount > previous.userMessageCount
                if changedConversation || sentMessage {
                    scrollState.reset()
                }
                if scrollState.shouldFollowLatest {
                    scrollToLatest(proxy, animated: sentMessage && !changedConversation)
                }
            }
        }
    }

    private func isAtBottom(_ geometry: ScrollGeometry) -> Bool {
        geometry.contentSize.height - (geometry.contentOffset.y + geometry.containerSize.height - geometry.contentInsets.bottom) <= 24
    }

    private func scrollToLatest(_ proxy: ScrollViewProxy, animated: Bool) {
        withAnimation(animated && !reduceMotion ? .snappy : nil) {
            proxy.scrollTo(Self.bottomAnchor, anchor: .bottom)
        }
    }
}
