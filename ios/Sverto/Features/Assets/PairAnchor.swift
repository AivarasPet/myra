import SwiftUI

struct PairAnchor: View {
    let label: String
    let switchable: Bool
    let action: () -> Void

    var body: some View {
        if switchable {
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(label)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .accessibilityHidden(true)
                }
                .font(.subheadline.weight(.medium))
                .frame(minHeight: 44)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .accessibilityLabel("\(label). Change pair")
        } else {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PairAnchor(label: "AAPL/USD", switchable: true) {}
        PairAnchor(label: "AAPL/USD", switchable: false) {}
    }
    .padding()
}
