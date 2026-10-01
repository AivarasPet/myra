import Testing
@testable import Sverto

private let accountA = "11111111-1111-1111-1111-111111111111"

private func purchaseState(amount: String) -> TransactionFormState {
    TransactionFormState(
        transactionId: "tx-1",
        date: 1_753_000_000,
        description: "CASHBACK",
        categoryId: 7,
        categoryName: "Miscellaneous",
        primaryEntry: EntryFormState(
            entryId: 42,
            accountId: accountA,
            accountName: "Main",
            assetId: 1,
            assetDisplay: "GBP — Pound Sterling",
            amount: amount
        )
    )
}

private func buyAssetState() -> TransactionFormState {
    TransactionFormState(
        transactionId: "tx-2",
        date: 1_753_000_000,
        primaryEntry: EntryFormState(
            entryId: 10,
            accountId: accountA,
            accountName: "Main",
            assetId: 5,
            assetDisplay: "AAPL — Apple",
            amount: "3"
        ),
        secondaryEntry: EntryFormState(
            entryId: 11,
            accountId: nil,
            accountName: "",
            assetId: 1,
            assetDisplay: "GBP — Pound Sterling",
            amount: "100"
        )
    )
}

private func config(_ key: String) -> TransactionTypeConfig {
    TransactionTypeConfig.forKey(key)
}

private func convert(_ state: TransactionFormState, from: String, to: String) -> TransactionFormState {
    TypeConversion.convert(state, from: config(from), to: config(to))
}

struct TypeConversionTests {
    @Test func sameTypeReturnsStateUnchanged() {
        let state = purchaseState(amount: "70")
        #expect(convert(state, from: "regular_transaction", to: "regular_transaction") == state)
    }

    @Test func singleToSingleCarriesEntryAndUsesMagnitude() {
        let result = convert(purchaseState(amount: "70"), from: "regular_transaction", to: "cash_transfer_in")
        #expect(result.primaryEntry.accountId == accountA)
        #expect(result.primaryEntry.assetId == 1)
        #expect(result.primaryEntry.entryId == 42)
        #expect(result.primaryEntry.amount == "70")
    }

    @Test func negativeSingleToPositiveSingleUsesMagnitude() {
        let result = convert(purchaseState(amount: "-10"), from: "regular_transaction", to: "cash_transfer_in")
        #expect(result.primaryEntry.amount == "10")
    }

    @Test func fixedSignSingleToAnySignSingleRestoresTheSign() {
        let result = convert(purchaseState(amount: "50"), from: "cash_transfer_out", to: "regular_transaction")
        #expect(result.primaryEntry.amount == "-50")
    }

    @Test func positiveSingleToDualFillsTheDestinationSlot() {
        let result = convert(purchaseState(amount: "70"), from: "regular_transaction", to: "cash_balance_transfer")
        #expect(result.secondaryEntry.accountId == accountA)
        #expect(result.secondaryEntry.entryId == 42)
        #expect(result.primaryEntry.accountId == nil)
        #expect(result.primaryEntry.entryId == nil)
    }

    @Test func negativeSingleToDualFillsTheSourceSlot() {
        let result = convert(purchaseState(amount: "-10"), from: "regular_transaction", to: "cash_balance_transfer")
        #expect(result.primaryEntry.accountId == accountA)
        #expect(result.primaryEntry.entryId == 42)
        #expect(result.secondaryEntry.accountId == nil)
    }

    @Test func sharedFieldsCollapseOntoPrimary() {
        let result = convert(purchaseState(amount: "70"), from: "regular_transaction", to: "cash_balance_transfer")
        #expect(result.primaryEntry.amount == "70")
        #expect(result.primaryEntry.assetId == 1)
    }

    @Test func blankAmountFallsBackToThePrimarySlot() {
        let result = convert(purchaseState(amount: ""), from: "regular_transaction", to: "cash_balance_transfer")
        #expect(result.primaryEntry.accountId == accountA)
        #expect(result.secondaryEntry.accountId == nil)
    }

    @Test func roundTripThroughADualTypeKeepsTheAccountAndSign() {
        let dual = convert(purchaseState(amount: "70"), from: "regular_transaction", to: "cash_balance_transfer")
        let back = convert(dual, from: "cash_balance_transfer", to: "regular_transaction")
        #expect(back.primaryEntry.accountId == accountA)
        #expect(back.primaryEntry.amount == "70")
        #expect(back.primaryEntry.entryId == 42)
    }

    @Test func dualToSinglePrefersAPopulatedLegOverAnEmptyPrimary() {
        let dual = convert(purchaseState(amount: "70"), from: "regular_transaction", to: "cash_balance_transfer")
        let result = convert(dual, from: "cash_balance_transfer", to: "cash_transfer_in")
        #expect(result.primaryEntry.accountId == accountA)
        #expect(result.primaryEntry.amount == "70")
    }

    @Test func dualToSinglePicksTheSignMatchingLeg() {
        let result = convert(buyAssetState(), from: "asset_purchase", to: "cash_transfer_out")
        #expect(result.primaryEntry.assetId == 1)
        #expect(result.primaryEntry.entryId == 11)
        #expect(result.primaryEntry.amount == "100")
    }

    @Test func dualToSingleUsesTheSameAccountWhenTheSourceSharedIt() {
        let result = convert(buyAssetState(), from: "asset_purchase", to: "cash_transfer_out")
        #expect(result.primaryEntry.accountId == accountA)
    }

    @Test func dualToDualIsPositional() {
        let result = convert(buyAssetState(), from: "asset_purchase", to: "asset_sale")
        #expect(result.primaryEntry.assetId == 5)
        #expect(result.primaryEntry.entryId == 10)
        #expect(result.primaryEntry.amount == "3")
        #expect(result.secondaryEntry.assetId == 1)
        #expect(result.secondaryEntry.entryId == 11)
        #expect(result.secondaryEntry.amount == "100")
    }

    @Test func sharedFieldsRetainDescriptionCategoryAndTransactionId() {
        let result = convert(purchaseState(amount: "70"), from: "regular_transaction", to: "cash_transfer_in")
        #expect(result.description == "CASHBACK")
        #expect(result.categoryId == 7)
        #expect(result.transactionId == "tx-1")
        #expect(result.date == 1_753_000_000)
    }
}
