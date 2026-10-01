import SwiftUI

struct LabeledPickerField: View {
    let label: String
    let value: String
    var isPlaceholder = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.body)
                        .foregroundStyle(isPlaceholder ? .secondary : .primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Form {
        LabeledPickerField(label: "Base pair asset", value: "USD — US Dollar") {}
        LabeledPickerField(label: "Base pair asset", value: "Select base asset", isPlaceholder: true) {}
    }
}
