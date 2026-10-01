import Foundation
import SvertoCore

nonisolated struct EntryFormState: Hashable {
    var entryId: Int32?
    var accountId: String?
    var accountName = ""
    var assetId: Int32?
    var assetDisplay = ""
    var amount = ""

    func withAsset(_ asset: AssetItem) -> EntryFormState {
        guard assetId == nil else { return self }
        var filled = self
        filled.assetId = asset.id
        filled.assetDisplay = asset.display
        return filled
    }
}

nonisolated struct TransactionFormState: Hashable, CategorizedForm {
    var transactionId: String?
    var date: Int64?
    var description = ""
    var categoryId: Int32?
    var categoryName = ""
    var categoryFromAi = false
    var originAssetId: Int32?
    var originAssetDisplay = ""
    var primaryEntry = EntryFormState()
    var secondaryEntry = EntryFormState()
}

nonisolated enum SubmitState: Hashable {
    case idle
    case submitting
    case success
}

nonisolated enum CorrectionState: Hashable {
    case idle
    case sending
    case updated
}

nonisolated struct CorrectionTypeChange: Hashable {
    let quickUploadId: String
    let newProposalType: ProposalType
}

extension AssetItem {
    nonisolated var display: String { "\(ticker) — \(name)" }
}

nonisolated enum EditableAmount {
    static func string(_ value: Double) -> String {
        guard value != 0, value.isFinite else { return "0" }
        let shortest = String(value)
        guard let decimal = Decimal(string: shortest, locale: Locale(identifier: "en_US_POSIX")) else { return shortest }
        return "\(decimal)"
    }

    static func signed(_ raw: String, sign: AmountSign) -> Double? {
        guard let parsed = Double(raw.trimmingCharacters(in: .whitespaces)) else { return nil }
        switch sign {
        case .positive: return abs(parsed)
        case .negative: return -abs(parsed)
        case .any: return parsed
        }
    }
}

extension String {
    nonisolated var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
