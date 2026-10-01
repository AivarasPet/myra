import SwiftUI

struct PanelAmountField: View {
    let label: String
    let value: String
    let sign: AmountSign
    let field: FormField
    let focus: FocusState<FormField?>.Binding
    let onChange: (String) -> Void

    @State private var text: String

    init(label: String, value: String, sign: AmountSign, field: FormField, focus: FocusState<FormField?>.Binding, onChange: @escaping (String) -> Void) {
        self.label = label
        self.value = value
        self.sign = sign
        self.field = field
        self.focus = focus
        self.onChange = onChange
        _text = State(initialValue: value)
    }

    private var signSymbol: String {
        switch sign {
        case .positive: "+"
        case .negative: "−"
        case .any: "#"
        }
    }

    private var signColor: Color {
        switch sign {
        case .positive: .gain
        case .negative: .loss
        case .any: .secondary
        }
    }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            Text(signSymbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(signColor)
                .frame(width: 36, height: 36)
                .background(signColor.opacity(0.16), in: .rect(cornerRadius: 11, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("0", text: $text)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .keyboardType(.decimalPad)
                    .focused(focus, equals: field)
                    .accessibilityLabel(label)
            }
        }
        .onChange(of: value) { _, newValue in
            if newValue != text { text = newValue }
        }
        .onChange(of: text) { _, typed in
            let filtered = AmountInputFilter.filter(typed, allowNegative: false)
            if filtered != typed {
                text = filtered
            } else if filtered != value {
                onChange(filtered)
            }
        }
    }
}
