import SwiftUI
import UIKit

struct CorrectionInput: View {
    let state: CorrectionState
    let focus: FocusState<FormField?>.Binding
    let onSend: (String) -> Void

    @State private var isExpanded = false
    @State private var text = ""
    @State private var showsCompletion = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isSending: Bool { state == .sending }
    private var canSend: Bool { !text.isBlank && !isSending }

    var body: some View {
        Section {
            Button {
                withAnimation(reduceMotion ? nil : .snappy) { isExpanded.toggle() }
            } label: {
                Label(isExpanded ? "Hide AI corrections" : "Ask AI to adjust", systemImage: "sparkles")
            }
            if showsCompletion {
                Label("AI changes applied. Review before saving.", systemImage: "checkmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if isExpanded {
                switch state {
                case .sending:
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Working on it…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                case .updated, .idle:
                    EmptyView()
                }
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Tell the AI what to change…", text: $text, axis: .vertical)
                        .lineLimit(1...3)
                        .disabled(isSending)
                        .focused(focus, equals: .correction)
                    Button(action: send) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.borderless)
                    .disabled(!canSend)
                    .accessibilityLabel("Send correction")
                }
                Text("e.g. \"the date is March 7\" or \"category should be Groceries\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: state, initial: true) { _, newState in
            if newState == .sending {
                showsCompletion = false
            } else if newState == .updated {
                showsCompletion = true
                UIAccessibility.post(notification: .announcement, argument: "AI changes applied. Review before saving.")
            }
        }
    }

    private func send() {
        guard canSend else { return }
        onSend(text.trimmingCharacters(in: .whitespacesAndNewlines))
        text = ""
    }
}
