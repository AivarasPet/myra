import SwiftUI
import SvertoCore

nonisolated func transactionTypeSymbol(_ transactionType: String) -> String {
    switch transactionType {
    case "asset_purchase": "cart"
    case "asset_sale", "cash_dividend", "asset_dividend": "banknote"
    case "cash_transfer_in", "asset_transfer_in": "arrow.down.left"
    case "cash_transfer_out", "asset_transfer_out": "arrow.up.right"
    case "asset_trade", "asset_balance_transfer": "arrow.left.arrow.right"
    case "cash_balance_transfer": "arrow.triangle.2.circlepath"
    case "account_fees": "receipt"
    case "group": "square.3.layers.3d"
    default: "building.columns"
    }
}

nonisolated func signedSecondaryAmount(_ text: String) -> String {
    text.hasPrefix("-") ? text : "+\(text)"
}

struct TransactionGlyph: View {
    private let transaction: TransactionListItem
    private let size: CGFloat

    init(transaction: TransactionListItem, size: CGFloat = Layout.rowGlyphSize) {
        self.transaction = transaction
        self.size = size
    }

    var body: some View {
        IconTile(size: size) { side in
            if transaction.categoryIcon.isEmpty {
                Image(systemName: transactionTypeSymbol(transaction.transactionType))
            } else {
                LucideIcon(name: transaction.categoryIcon, size: side / 2)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(transaction.categoryName.isEmpty ? transaction.typeLabel : transaction.categoryName)
    }
}

struct TransactionAmount: View {
    private let transaction: TransactionListItem
    private let lineLimit: Int?

    init(transaction: TransactionListItem, lineLimit: Int? = 1) {
        self.transaction = transaction
        self.lineLimit = lineLimit
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(transaction.amountDisplay)
                .font(.body)
                .monospacedDigit()
                .lineLimit(lineLimit)
            if let secondary = transaction.secondaryAmountDisplay {
                Text(signedSecondaryAmount(secondary))
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .lineLimit(lineLimit)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
