import SwiftUI

struct PickerRow: View {
    let label: String
    let value: String
    let placeholder: String
    let systemImage: String
    var tint: Color = .brand
    var aiLoading = false
    var aiFilled = false
    let action: () -> Void

    private var isEmpty: Bool { value.isBlank }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.rowSpacing) {
                Image(systemName: systemImage)
                    .font(.body.weight(.medium))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.14), in: .rect(cornerRadius: 11, style: .continuous))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(isEmpty ? placeholder : value)
                        .font(.body.weight(.medium))
                        .foregroundStyle(isEmpty ? .secondary : .primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                if aiFilled {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.brand)
                        .accessibilityLabel("AI suggested")
                }
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .padding(6)
            .aiThinkingBorder(active: aiLoading)
            .padding(-6)
        }
        .foregroundStyle(.primary)
        .accessibilityLabel(label)
        .accessibilityValue([isEmpty ? "Not set" : value, aiFilled ? "AI suggested" : nil].compactMap { $0 }.joined(separator: ", "))
    }
}
