import SvertoCore
import SwiftUI

struct AccountIdentifiersSection: View {
    let identifiers: [AccountIdentifier]
    let onRemove: (AccountIdentifier) -> Void
    let onAdd: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Section("Account identifiers") {
            ForEach(identifiers, id: \.self) { identifier in
                let label = AccountIdentifierKind.label(forKey: identifier.kind)
                let shown = AccountIdentifierKind.displayValue(identifier)
                HStack(spacing: 12) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(label)
                            Text(shown)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityElement(children: .combine)
                    } else {
                        LabeledContent(label) {
                            Text(shown)
                                .monospacedDigit()
                        }
                    }
                    Button {
                        onRemove(identifier)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Remove \(label) \(shown)")
                }
            }
            .onDelete { offsets in
                offsets.map { identifiers[$0] }.forEach(onRemove)
            }
            Button("Add identifier", systemImage: "plus", action: onAdd)
        }
    }
}
