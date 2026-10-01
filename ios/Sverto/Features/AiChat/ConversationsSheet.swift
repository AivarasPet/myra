import SvertoCore
import SwiftUI

struct ConversationsSheet: View {
    let model: AiChatViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var pendingDelete: ConversationItem?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        model.startNewConversation()
                        dismiss()
                    } label: {
                        Label("New chat", systemImage: "square.and.pencil")
                    }
                }
                if model.conversations.isEmpty {
                    ContentUnavailableView(
                        "No conversations yet",
                        systemImage: "bubble.left.and.text.bubble.right",
                        description: Text("Start a new chat to ask Myra about your finances.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    Section("Recent") {
                        ForEach(model.conversations, id: \.id) { conversation in
                            ConversationRow(conversation: conversation, isSelected: conversation.id == model.activeConversationId) {
                                model.selectConversation(id: conversation.id)
                                dismiss()
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    pendingDelete = conversation
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .refreshable { await model.loadConversations() }
            .confirmationDialog(
                "Delete this conversation?",
                isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
                titleVisibility: .visible,
                presenting: pendingDelete
            ) { conversation in
                Button("Delete conversation", role: .destructive) {
                    model.deleteConversation(id: conversation.id)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct ConversationRow: View {
    let conversation: ConversationItem
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            HStack {
                Text(conversation.title)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
        }
        .foregroundStyle(Color.primary)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
