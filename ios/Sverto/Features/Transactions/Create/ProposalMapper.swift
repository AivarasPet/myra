import Foundation
import SvertoCore

nonisolated struct ProposalSummary: Hashable {
    let description: String
    let date: String
    let amount: String?
    let currency: String?
}

nonisolated enum ProposalMapper {
    static func summary(proposalData: String?) -> ProposalSummary? {
        guard let proposalData, let data = jsonObject(proposalData) else { return nil }
        return ProposalSummary(
            description: string(data["description"]) ?? "Receipt",
            date: string(data["date"]) ?? "",
            amount: string(data["amount"]),
            currency: string(data["currency"])
        )
    }

    static func formState(proposalData: String, lookupTables: String, now: Date = Date()) -> TransactionFormState? {
        guard let data = jsonObject(proposalData) else { return nil }
        let lookups = jsonObject(lookupTables) ?? [:]
        let accountId = string(data["account_id"]).flatMap { $0.isEmpty ? nil : $0 }
        let assetId = int(data["asset_id"]).flatMap { $0 == 0 ? nil : $0 }
        let categoryId = int(data["category_id"])
        return TransactionFormState(
            date: date(string(data["date"]), now: now),
            description: string(data["description"]) ?? "",
            categoryId: categoryId,
            categoryName: categoryName(categoryId, lookups: lookups),
            primaryEntry: EntryFormState(
                accountId: accountId,
                accountName: accountName(accountId, lookups: lookups),
                assetId: assetId,
                assetDisplay: assetDisplay(assetId, lookups: lookups),
                amount: string(data["amount"]) ?? ""
            )
        )
    }

    static func groupFormState(proposalData: String, lookupTables: String, now: Date = Date()) -> GroupFormState? {
        guard let data = jsonObject(proposalData) else { return nil }
        let lookups = jsonObject(lookupTables) ?? [:]
        let groupDate = date(string(data["date"]), now: now)
        let categoryId = int(data["category_id"])
        let regular = TransactionTypeConfig.regularTransaction
        let children = (data["transactions"] as? [Any] ?? []).enumerated().compactMap { index, raw -> IdentifiedGroupTransaction? in
            guard let child = raw as? [String: Any] else { return nil }
            let accountId = string(child["account_id"]) ?? ""
            let assetId = int(child["asset_id"]) ?? 0
            let childCategoryId = int(child["category_id"])
            let amount = string(child["amount"]) ?? "0"
            let description = string(child["description"]) ?? ""
            let input = CreateTransactionInput(
                transactionId: nil,
                typeKey: regular.apiType,
                date: groupDate,
                primaryEntryId: nil,
                primaryAccountId: accountId,
                primaryAssetId: assetId,
                primaryAmount: Double(amount) ?? 0,
                secondaryEntryId: nil,
                secondaryAccountId: nil,
                secondaryAssetId: nil,
                secondaryAmount: nil,
                originAssetId: nil,
                categoryId: childCategoryId,
                description: description.isBlank ? nil : description
            )
            return IdentifiedGroupTransaction(GroupTransactionItem(
                input: input,
                descriptionDisplay: description.isBlank ? "Transaction \(index + 1)" : description,
                typeLabel: regular.label,
                amountDisplay: EditableAmount.string(Double(amount) ?? 0),
                accountName: accountName(accountId, lookups: lookups),
                assetDisplay: assetDisplay(assetId, lookups: lookups),
                categoryName: categoryName(childCategoryId, lookups: lookups)
            ))
        }
        return GroupFormState(
            date: groupDate,
            description: string(data["description"]) ?? "",
            categoryId: categoryId,
            categoryName: categoryName(categoryId, lookups: lookups),
            transactions: children
        )
    }

    static func utcMidnight(isoDate: String) -> Int64? {
        let parts = isoDate.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2]),
              (1...12).contains(month), (1...31).contains(day) else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { return nil }
        return Int64(date.timeIntervalSince1970)
    }

    private static func date(_ isoDate: String?, now: Date) -> Int64 {
        isoDate.flatMap(utcMidnight) ?? Int64(now.timeIntervalSince1970)
    }

    private static func jsonObject(_ text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    private static func string(_ value: Any?) -> String? {
        switch value {
        case let text as String: text
        case let number as NSNumber: number.stringValue
        default: nil
        }
    }

    private static func int(_ value: Any?) -> Int32? {
        switch value {
        case let number as NSNumber: Int32(exactly: number.intValue)
        case let text as String: Int32(text)
        default: nil
        }
    }

    private static func accountName(_ accountId: String?, lookups: [String: Any]) -> String {
        guard let accountId else { return "" }
        let accounts = lookups["accounts"] as? [[String: Any]] ?? []
        return accounts.first { string($0["account_id"]) == accountId }.flatMap { string($0["name"]) } ?? ""
    }

    private static func assetDisplay(_ assetId: Int32?, lookups: [String: Any]) -> String {
        guard let assetId, assetId != 0 else { return "" }
        let assets = lookups["assets"] as? [[String: Any]] ?? []
        guard let asset = assets.first(where: { int($0["asset_id"]) == assetId }) else { return "" }
        let ticker = string(asset["ticker"]) ?? ""
        let name = string(asset["name"]) ?? ""
        return ticker.isEmpty ? name : "\(ticker) — \(name)"
    }

    private static func categoryName(_ categoryId: Int32?, lookups: [String: Any]) -> String {
        guard let categoryId else { return "" }
        let categories = lookups["categories"] as? [[String: Any]] ?? []
        return categories.first { int($0["id"]) == categoryId }.flatMap { string($0["category"]) } ?? ""
    }
}
