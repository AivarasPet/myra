import SvertoCore
import SwiftUI

struct AccountTransactionRow: View {
    let transaction: TransactionListItem
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var subtitle: String {
        transaction.categoryName.isEmpty ? transaction.typeLabel : transaction.categoryName
    }

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Layout.rowSpacing))
            : AnyLayout(HStackLayout(spacing: Layout.rowSpacing))
        layout {
            TransactionGlyph(transaction: transaction)
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.body)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 8)
            }
            TransactionAmount(transaction: transaction, lineLimit: dynamicTypeSize.isAccessibilitySize ? nil : 1)
                .foregroundStyle(Color.primary, Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.primary)
        .opacity(transaction.visibility == .ghost ? 0.55 : 1)
        .accessibilityElement(children: .combine)
    }
}
