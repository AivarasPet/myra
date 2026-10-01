import SwiftUI

struct ReasoningCard: View {
    let content: String
    let isStreaming: Bool

    @State private var isExpanded: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(content: String, isStreaming: Bool) {
        self.content = content
        self.isStreaming = isStreaming
        _isExpanded = State(initialValue: isStreaming)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(reduceMotion ? nil : .snappy) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 10) {
                    if isStreaming {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "brain")
                            .font(.footnote)
                            .foregroundStyle(.tint)
                    }
                    title
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.leading, 12)
                .padding(.trailing, 14)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .background(.cardFill, in: .capsule)
                .overlay(Capsule().strokeBorder(Color(.separator), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isStreaming ? "Thinking" : "Thought process")
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityAddTraits(.isButton)

            if isExpanded {
                HStack(alignment: .top, spacing: 16) {
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 2)
                    Text(content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .padding(.trailing, 4)
                }
                .padding(.leading, 6)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .onChange(of: isStreaming) { _, streaming in
            if !streaming {
                withAnimation(reduceMotion ? nil : .snappy) { isExpanded = false }
            }
        }
    }

    @ViewBuilder
    private var title: some View {
        let label = Text(isStreaming ? "Thinking…" : "Thought process")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
        if isStreaming {
            label.shimmering()
        } else {
            label
        }
    }
}
