import SwiftUI

struct GroupTransactionRow: View {
    let index: Int
    let item: GroupTransactionItem
    let onEdit: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: Layout.rowSpacing) {
                Text("\(index + 1).")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.descriptionDisplay)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(item.typeLabel) · \(item.amountWithUnit)")
                        .font(.footnote)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(.primary)
        .accessibilityHint("Opens the transaction for editing")
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Remove", systemImage: "trash", role: .destructive, action: onRemove)
        }
        .contextMenu {
            Button("Remove", systemImage: "trash", role: .destructive, action: onRemove)
        }
    }
}
