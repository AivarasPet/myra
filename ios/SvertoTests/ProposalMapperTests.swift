import Foundation
import SvertoCore
import Testing
@testable import Sverto

private let mainAccount = "3f2b6c1e-9d4a-4b7f-8c2e-1a5d7e9f0b21"
private let savingsAccount = "7a1c2d3e-4f5a-4b6c-8d7e-9f0a1b2c3d4e"
private let fixedNow = Date(timeIntervalSince1970: 1_753_000_000)

private let lookupTables = """
{
  "accounts": [
    { "account_id": "\(mainAccount)", "name": "Main" },
    { "account_id": "\(savingsAccount)", "name": "Savings" }
  ],
  "assets": [
    { "asset_id": 1, "ticker": "GBP", "name": "Pound Sterling" },
    { "asset_id": 2, "ticker": "EUR", "name": "Euro" },
    { "asset_id": 9, "ticker": "", "name": "Loyalty points" }
  ],
  "categories": [
    { "id": 25, "category": "Groceries" },
    { "id": 7, "category": "Miscellaneous" }
  ]
}
"""

private let individualProposal = """
{
  "description": "Tesco Express",
  "date": "2026-07-20",
  "account_id": "\(mainAccount)",
  "asset_id": 1,
  "category_id": 25,
  "amount": "-23.45",
  "currency": "GBP"
}
"""

private let groupProposal = """
{
  "description": "Weekend shopping",
  "date": "2026-07-19",
  "category_id": 7,
  "transactions": [
    { "account_id": "\(mainAccount)", "asset_id": 1, "category_id": 25, "amount": "-12.5", "description": "Bread and milk" },
    { "account_id": "\(savingsAccount)", "asset_id": 2, "category_id": null, "amount": "-4", "description": "   " },
    { "account_id": "\(mainAccount)", "asset_id": 9, "amount": "30", "description": "" }
  ]
}
"""

private let july20Utc: Int64 = 1_784_505_600
private let july19Utc: Int64 = 1_784_419_200

struct ProposalSummaryTests {
    @Test func mapsEveryFieldFromProposalJson() {
        let summary = ProposalMapper.summary(proposalData: individualProposal)

        #expect(summary == ProposalSummary(description: "Tesco Express", date: "2026-07-20", amount: "-23.45", currency: "GBP"))
    }

    @Test func missingFieldsFallBackToReceiptAndEmptyDate() {
        let summary = ProposalMapper.summary(proposalData: "{}")

        #expect(summary == ProposalSummary(description: "Receipt", date: "", amount: nil, currency: nil))
    }

    @Test func numericAmountIsStringified() {
        let summary = ProposalMapper.summary(proposalData: #"{"amount": 12.5}"#)

        #expect(summary?.amount == "12.5")
    }

    @Test func nilInvalidAndNonObjectJsonYieldNil() {
        #expect(ProposalMapper.summary(proposalData: nil) == nil)
        #expect(ProposalMapper.summary(proposalData: "") == nil)
        #expect(ProposalMapper.summary(proposalData: "not json") == nil)
        #expect(ProposalMapper.summary(proposalData: "[1, 2]") == nil)
    }
}

struct ProposalFormStateTests {
    @Test func mapsIndividualProposalIntoPurchaseForm() throws {
        let state = try #require(ProposalMapper.formState(proposalData: individualProposal, lookupTables: lookupTables, now: fixedNow))

        #expect(state.transactionId == nil)
        #expect(state.date == july20Utc)
        #expect(state.description == "Tesco Express")
        #expect(state.categoryId == 25)
        #expect(state.categoryName == "Groceries")
        #expect(state.primaryEntry == EntryFormState(
            entryId: nil,
            accountId: mainAccount,
            accountName: "Main",
            assetId: 1,
            assetDisplay: "GBP — Pound Sterling",
            amount: "-23.45"
        ))
        #expect(state.secondaryEntry == EntryFormState())
        #expect(state.originAssetId == nil)
        #expect(!state.categoryFromAi)
    }

    @Test func missingDateFallsBackToNow() throws {
        let state = try #require(ProposalMapper.formState(proposalData: #"{"description": "x"}"#, lookupTables: lookupTables, now: fixedNow))

        #expect(state.date == Int64(fixedNow.timeIntervalSince1970))
    }

    @Test func malformedDateFallsBackToNow() throws {
        for raw in ["20-07-2026", "2026/07/20", "2026-13-01", "2026-07-32", "yesterday", ""] {
            let state = try #require(ProposalMapper.formState(proposalData: #"{"date": "\#(raw)"}"#, lookupTables: lookupTables, now: fixedNow))

            #expect(state.date == Int64(fixedNow.timeIntervalSince1970))
        }
    }

    @Test func emptyAccountAndZeroAssetAreTreatedAsUnset() throws {
        let state = try #require(ProposalMapper.formState(
            proposalData: #"{"account_id": "", "asset_id": 0, "amount": "5"}"#,
            lookupTables: lookupTables,
            now: fixedNow
        ))

        #expect(state.primaryEntry.accountId == nil)
        #expect(state.primaryEntry.accountName == "")
        #expect(state.primaryEntry.assetId == nil)
        #expect(state.primaryEntry.assetDisplay == "")
        #expect(state.primaryEntry.amount == "5")
    }

    @Test func unknownLookupIdsKeepIdsButBlankDisplayNames() throws {
        let state = try #require(ProposalMapper.formState(
            proposalData: #"{"account_id": "unknown", "asset_id": 404, "category_id": 999}"#,
            lookupTables: lookupTables,
            now: fixedNow
        ))

        #expect(state.primaryEntry.accountId == "unknown")
        #expect(state.primaryEntry.accountName == "")
        #expect(state.primaryEntry.assetId == 404)
        #expect(state.primaryEntry.assetDisplay == "")
        #expect(state.categoryId == 999)
        #expect(state.categoryName == "")
    }

    @Test func assetWithoutTickerDisplaysNameOnly() throws {
        let state = try #require(ProposalMapper.formState(proposalData: #"{"asset_id": 9}"#, lookupTables: lookupTables, now: fixedNow))

        #expect(state.primaryEntry.assetDisplay == "Loyalty points")
    }

    @Test func numericIdsMayArriveAsStrings() throws {
        let state = try #require(ProposalMapper.formState(
            proposalData: #"{"asset_id": "2", "category_id": "7", "amount": 3}"#,
            lookupTables: lookupTables,
            now: fixedNow
        ))

        #expect(state.primaryEntry.assetId == 2)
        #expect(state.primaryEntry.assetDisplay == "EUR — Euro")
        #expect(state.categoryId == 7)
        #expect(state.categoryName == "Miscellaneous")
        #expect(state.primaryEntry.amount == "3")
    }

    @Test func missingAmountAndDescriptionBecomeEmptyStrings() throws {
        let state = try #require(ProposalMapper.formState(proposalData: "{}", lookupTables: lookupTables, now: fixedNow))

        #expect(state.description == "")
        #expect(state.primaryEntry.amount == "")
        #expect(state.categoryId == nil)
    }

    @Test func invalidLookupTablesAreToleratedAsEmpty() throws {
        let state = try #require(ProposalMapper.formState(proposalData: individualProposal, lookupTables: "garbage", now: fixedNow))

        #expect(state.primaryEntry.accountId == mainAccount)
        #expect(state.primaryEntry.accountName == "")
        #expect(state.categoryName == "")
    }

    @Test func invalidProposalYieldsNil() {
        #expect(ProposalMapper.formState(proposalData: "", lookupTables: lookupTables, now: fixedNow) == nil)
        #expect(ProposalMapper.formState(proposalData: "[]", lookupTables: lookupTables, now: fixedNow) == nil)
    }
}

struct ProposalGroupFormStateTests {
    private func children() throws -> [GroupTransactionItem] {
        try #require(ProposalMapper.groupFormState(proposalData: groupProposal, lookupTables: lookupTables)).transactions.map(\.item)
    }

    @Test func mapsGroupHeaderFields() throws {
        let state = try #require(ProposalMapper.groupFormState(proposalData: groupProposal, lookupTables: lookupTables))

        #expect(state.date == july19Utc)
        #expect(state.description == "Weekend shopping")
        #expect(state.categoryId == 7)
        #expect(state.categoryName == "Miscellaneous")
        #expect(!state.categoryFromAi)
        #expect(state.transactions.count == 3)
    }

    @Test func childrenGetDistinctIdentities() throws {
        let state = try #require(ProposalMapper.groupFormState(proposalData: groupProposal, lookupTables: lookupTables))

        #expect(Set(state.transactions.map(\.id)).count == 3)
    }

    @Test func childrenArePurchasesOnTheGroupDate() throws {
        for child in try children() {
            #expect(child.input.typeKey == "regular")
            #expect(child.typeLabel == TransactionTypeCatalog.regular.label)
            #expect(child.input.date == july19Utc)
            #expect(child.input.transactionId == nil)
            #expect(child.input.primaryEntryId == nil)
            #expect(child.input.secondaryAccountId == nil)
            #expect(child.input.secondaryAssetId == nil)
            #expect(child.input.secondaryAmount == nil)
            #expect(child.input.originAssetId == nil)
        }
    }

    @Test func firstChildResolvesEveryLookup() throws {
        let child = try #require(children().first)

        #expect(child.input.primaryAccountId == mainAccount)
        #expect(child.input.primaryAssetId == 1)
        #expect(child.input.primaryAmount == -12.5)
        #expect(child.input.categoryId == 25)
        #expect(child.input.description == "Bread and milk")
        #expect(child.descriptionDisplay == "Bread and milk")
        #expect(child.amountDisplay == "-12.5")
        #expect(child.accountName == "Main")
        #expect(child.assetDisplay == "GBP — Pound Sterling")
        #expect(child.categoryName == "Groceries")
    }

    @Test func blankChildDescriptionsUsePositionalPlaceholdersAndNilInput() throws {
        let items = try children()

        #expect(items[1].descriptionDisplay == "Transaction 2")
        #expect(items[1].input.description == nil)
        #expect(items[2].descriptionDisplay == "Transaction 3")
        #expect(items[2].input.description == nil)
    }

    @Test func nullChildCategoryIsUnset() throws {
        let child = try children()[1]

        #expect(child.input.categoryId == nil)
        #expect(child.categoryName == "")
        #expect(child.accountName == "Savings")
        #expect(child.assetDisplay == "EUR — Euro")
        #expect(child.amountDisplay == "-4")
    }

    @Test func integerAmountsDisplayWithoutTrailingZero() throws {
        let child = try children()[2]

        #expect(child.input.primaryAmount == 30)
        #expect(child.amountDisplay == "30")
        #expect(child.assetDisplay == "Loyalty points")
    }

    @Test func childrenMissingAmountOrIdsGetZeroDefaults() throws {
        let state = try #require(ProposalMapper.groupFormState(
            proposalData: #"{"transactions": [{}, {"amount": "abc"}]}"#,
            lookupTables: lookupTables
        ))
        let items = state.transactions.map(\.item)

        #expect(items.count == 2)
        for child in items {
            #expect(child.input.primaryAccountId == "")
            #expect(child.input.primaryAssetId == 0)
            #expect(child.input.primaryAmount == 0)
            #expect(child.amountDisplay == "0")
            #expect(child.accountName == "")
            #expect(child.assetDisplay == "")
        }
        #expect(items.map(\.descriptionDisplay) == ["Transaction 1", "Transaction 2"])
    }

    @Test func nonObjectChildrenAreSkippedButNumberingFollowsSourceIndex() throws {
        let state = try #require(ProposalMapper.groupFormState(
            proposalData: #"{"transactions": [1, {"amount": "2"}, "x", {"amount": "4"}]}"#,
            lookupTables: lookupTables
        ))

        #expect(state.transactions.map(\.item.descriptionDisplay) == ["Transaction 2", "Transaction 4"])
    }

    @Test func missingTransactionsArrayYieldsEmptyGroup() throws {
        let state = try #require(ProposalMapper.groupFormState(proposalData: #"{"description": "Empty"}"#, lookupTables: lookupTables))

        #expect(state.description == "Empty")
        #expect(state.transactions.isEmpty)
        #expect(state.categoryId == nil)
    }

    @Test func missingDateFallsBackToNow() throws {
        let state = try #require(ProposalMapper.groupFormState(proposalData: "{}", lookupTables: lookupTables, now: fixedNow))

        #expect(state.date == Int64(fixedNow.timeIntervalSince1970))
    }

    @Test func invalidProposalYieldsNil() {
        #expect(ProposalMapper.groupFormState(proposalData: "", lookupTables: lookupTables) == nil)
        #expect(ProposalMapper.groupFormState(proposalData: "[]", lookupTables: lookupTables) == nil)
    }
}

struct ProposalUtcMidnightTests {
    @Test func parsesIsoDateAsUtcMidnight() {
        #expect(ProposalMapper.utcMidnight(isoDate: "2026-07-20") == july20Utc)
        #expect(ProposalMapper.utcMidnight(isoDate: "1970-01-01") == 0)
        #expect(ProposalMapper.utcMidnight(isoDate: "2000-02-29") == 951_782_400)
    }

    @Test func rejectsMalformedDates() {
        #expect(ProposalMapper.utcMidnight(isoDate: "2026-07") == nil)
        #expect(ProposalMapper.utcMidnight(isoDate: "2026-07-20-01") == nil)
        #expect(ProposalMapper.utcMidnight(isoDate: "2026-00-10") == nil)
        #expect(ProposalMapper.utcMidnight(isoDate: "2026-13-10") == nil)
        #expect(ProposalMapper.utcMidnight(isoDate: "2026-07-00") == nil)
        #expect(ProposalMapper.utcMidnight(isoDate: "2026-07-32") == nil)
        #expect(ProposalMapper.utcMidnight(isoDate: "abcd-ef-gh") == nil)
        #expect(ProposalMapper.utcMidnight(isoDate: "") == nil)
    }
}
