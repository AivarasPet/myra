import Foundation
import SvertoCore

nonisolated struct IdentifiedGroupTransaction: Identifiable, Hashable {
    let id: UUID
    var item: GroupTransactionItem

    init(_ item: GroupTransactionItem, id: UUID = UUID()) {
        self.id = id
        self.item = item
    }
}

nonisolated struct GroupFormState: Hashable, CategorizedForm {
    var date: Int64?
    var description = ""
    var categoryId: Int32?
    var categoryName = ""
    var categoryFromAi = false
    var transactions: [IdentifiedGroupTransaction] = []
}

extension GroupTransactionItem {
    nonisolated var amountWithUnit: String {
        let unit = assetDisplay.components(separatedBy: " — ").first ?? ""
        return TransactionAmountPresentation.format(input.primaryAmount, unit: unit)
    }
}

nonisolated enum GroupFormSource {
    case new
    case edit(TransactionListItem)
    case selection([String])
    case proposal(String)
}
