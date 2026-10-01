import SwiftUI

struct ToolCallCard: View {
    let tool: ToolCallPart

    @State private var isExpanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var phase: ToolCallPhase { ToolCallPhase(state: tool.state) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(reduceMotion ? nil : .snappy) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    leadingTile
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(tool.name)
                                .foregroundStyle(Color.primary)
                                .font(.subheadline.weight(.semibold).monospaced())
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        status
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(12)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tool \(tool.name), \(phase.statusLabel)")
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    CodeBox(caption: "PARAMETERS", text: JsonPrettyPrinter.format(tool.params))
                    if let output = tool.output {
                        CodeBox(caption: "RESULT", text: JsonPrettyPrinter.format(output))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(.cardFill, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color(.separator), lineWidth: 1))
    }

    private var leadingTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(phase.tileTint.opacity(0.16))
            if phase == .running {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: phase.systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(phase.tileTint)
            }
        }
        .frame(width: 38, height: 38)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var status: some View {
        let label = Text(phase.statusLabel)
            .font(.caption)
            .foregroundStyle(phase.statusColor)
        if phase == .running {
            label.shimmering()
        } else {
            label
        }
    }
}

private struct CodeBox: View {
    let caption: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(caption)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemFill), in: .rect(cornerRadius: 12))
    }
}
