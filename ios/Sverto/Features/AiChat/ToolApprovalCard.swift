import SwiftUI

struct ToolApprovalCard: View {
    let toolName: String
    let params: String
    let onApprove: () -> Void
    let onDeny: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var rows: [ToolParamRow]? { ToolParamRows.parse(params) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner
            VStack(alignment: .leading, spacing: 12) {
                Text("Sverto wants to run this action.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                parameters
                actionLayout {
                    Button(action: onDeny) {
                        Label("Deny", systemImage: "xmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    Button(action: onApprove) {
                        Label("Approve", systemImage: "checkmark")
                            .foregroundStyle(Color.onAccent)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .controlSize(.large)
                .padding(.top, 4)
            }
            .padding(16)
        }
        .background(.cardFill, in: .rect(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(Color(.separator), lineWidth: 1))
        .clipShape(.rect(cornerRadius: 28))
    }

    private var actionLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 10))
    }

    private var metadataLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(spacing: 12))
    }

    private var banner: some View {
        metadataLayout {
            Label("Approval required", systemImage: "checkmark.shield")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primary)
            if !dynamicTypeSize.isAccessibilitySize { Spacer(minLength: 8) }
            Text(toolName)
                .font(.caption.monospaced())
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill))
    }

    @ViewBuilder
    private var parameters: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let rows {
                ForEach(rows) { row in
                    metadataLayout {
                        Text(row.key)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if !dynamicTypeSize.isAccessibilitySize { Spacer(minLength: 12) }
                        Text(row.value)
                            .font(.subheadline.weight(.medium))
                            .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 9)
                    if row.id != rows.last?.id {
                        Divider()
                    }
                }
            } else {
                Text(params)
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill), in: .rect(cornerRadius: 16))
    }
}
