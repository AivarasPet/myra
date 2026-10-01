import Foundation

nonisolated enum RequiredTransactionField: Hashable {
    case date
    case primaryAccount
    case primaryAsset
    case primaryAmount
    case secondaryAccount
    case secondaryAsset
    case secondaryAmount

    var message: String {
        switch self {
        case .date: "Choose a date."
        case .primaryAccount, .secondaryAccount: "Choose an account for this entry."
        case .primaryAsset, .secondaryAsset: "Choose an asset for this entry."
        case .primaryAmount, .secondaryAmount: "Enter a valid amount."
        }
    }
}

nonisolated enum TransactionFormValidation {
    static func missingFields(in form: TransactionFormState, config: TransactionTypeConfig) -> Set<RequiredTransactionField> {
        var fields: Set<RequiredTransactionField> = []
        if form.date == nil { fields.insert(.date) }
        if form.primaryEntry.accountId == nil { fields.insert(.primaryAccount) }
        if form.primaryEntry.assetId == nil { fields.insert(.primaryAsset) }
        if EditableAmount.signed(form.primaryEntry.amount, sign: config.entryMode.primarySign)?.isFinite != true {
            fields.insert(.primaryAmount)
        }
        if case let .dual(mode) = config.entryMode {
            if !mode.sameAccount, form.secondaryEntry.accountId == nil { fields.insert(.secondaryAccount) }
            if !mode.sameAsset, form.secondaryEntry.assetId == nil { fields.insert(.secondaryAsset) }
            if !mode.sharedAmount, EditableAmount.signed(form.secondaryEntry.amount, sign: mode.secondarySign)?.isFinite != true {
                fields.insert(.secondaryAmount)
            }
        }
        return fields
    }
}
