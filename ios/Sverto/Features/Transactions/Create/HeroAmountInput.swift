import SwiftUI

struct HeroAmountInput: View {
    let value: String
    let sign: AmountSign
    let autofocus: Bool
    let focus: FocusState<FormField?>.Binding
    let onChange: (String) -> Void

    @State private var text: String

    init(value: String, sign: AmountSign, autofocus: Bool, focus: FocusState<FormField?>.Binding, onChange: @escaping (String) -> Void) {
        self.value = value
        self.sign = sign
        self.autofocus = autofocus
        self.focus = focus
        self.onChange = onChange
        _text = State(initialValue: value)
    }

    private var prefix: String? {
        switch sign {
        case .positive: "+"
        case .negative: "−"
        case .any: nil
        }
    }

    private var prefixColor: Color {
        switch sign {
        case .positive: .gain
        case .negative: .loss
        case .any: .primary
        }
    }

    private var isNegative: Bool { text.hasPrefix("-") }

    private var numberFont: Font { .system(.largeTitle, design: .rounded, weight: .bold) }

    var body: some View {
        VStack(spacing: 6) {
            Text("Amount")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if let prefix {
                    Text(prefix)
                        .font(numberFont)
                        .foregroundStyle(prefixColor)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityHidden(true)
                }
                Text(text.isEmpty ? "0" : text)
                    .font(numberFont)
                    .monospacedDigit()
                    .lineLimit(1)
                    .frame(minWidth: 44)
                    .hidden()
                    .overlay {
                        TextField("0", text: $text)
                            .font(numberFont)
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .clipped()
                            .focused(focus, equals: .primaryAmount)
                            .accessibilityLabel("Amount")
                    }
            }
            .frame(maxWidth: .infinity)
            if sign == .any {
                signToggle
            }
        }
        .padding(.vertical, 12)
        .onAppear {
            guard autofocus else { return }
            Task { focus.wrappedValue = .primaryAmount }
        }
        .onChange(of: value) { _, newValue in
            if newValue != text { text = newValue }
        }
        .onChange(of: text) { _, typed in
            let filtered = AmountInputFilter.filter(typed, allowNegative: sign == .any)
            if filtered != typed {
                text = filtered
            } else if filtered != value {
                onChange(filtered)
            }
        }
    }

    private var signToggle: some View {
        Button {
            text = isNegative ? String(text.dropFirst()) : "-" + text
        } label: {
            Label {
                Text(isNegative ? "Expense" : "Income")
                    .foregroundStyle(isNegative ? Color.loss : Color.gain)
            } icon: {
                Image(systemName: isNegative ? "minus" : "plus")
                    .foregroundStyle(isNegative ? Color.loss : Color.gain)
            }
            .font(.footnote.weight(.semibold))
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .controlSize(.small)
        .tint(isNegative ? .loss : .gain)
        .accessibilityLabel("Amount sign")
        .accessibilityValue(isNegative ? "Negative" : "Positive")
        .accessibilityHint("Toggles between expense and income")
    }
}
