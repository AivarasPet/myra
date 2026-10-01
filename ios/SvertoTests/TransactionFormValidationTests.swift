import Testing
@testable import Sverto

struct TransactionFormValidationTests {
    @Test func emptySingleEntryIdentifiesEachMissingField() {
        let fields = TransactionFormValidation.missingFields(in: TransactionFormState(), config: .regularTransaction)

        #expect(fields == [.date, .primaryAccount, .primaryAsset, .primaryAmount])
    }

    @Test func sharedTransferFieldsDoNotRequireHiddenSecondaryInputs() {
        let form = TransactionFormState(
            date: 1,
            primaryEntry: EntryFormState(accountId: "source", assetId: 1, amount: "12.34"),
            secondaryEntry: EntryFormState(accountId: "destination")
        )

        #expect(TransactionFormValidation.missingFields(in: form, config: .forKey("cash_balance_transfer")).isEmpty)
    }

    @Test func assetPurchaseRequiresBothAmountsAndAssetsButOnlyOneAccount() {
        let form = TransactionFormState(
            date: 1,
            primaryEntry: EntryFormState(accountId: "broker", assetId: 4, amount: "0.004")
        )

        #expect(TransactionFormValidation.missingFields(in: form, config: .forKey("asset_purchase")) == [.secondaryAsset, .secondaryAmount])
    }

    @Test func validZeroAndNegativeAmountsRemainAccepted() {
        for amount in ["0", "-12.34", "0.00000001"] {
            let form = TransactionFormState(date: 1, primaryEntry: EntryFormState(accountId: "account", assetId: 1, amount: amount))

            #expect(TransactionFormValidation.missingFields(in: form, config: .regularTransaction).isEmpty)
        }
    }

    @Test func invalidAndNonfiniteAmountsAreIdentified() {
        for amount in ["-", ".", "nan", "inf", "1e999"] {
            let form = TransactionFormState(date: 1, primaryEntry: EntryFormState(accountId: "account", assetId: 1, amount: amount))

            #expect(TransactionFormValidation.missingFields(in: form, config: .regularTransaction) == [.primaryAmount])
        }
    }
}
