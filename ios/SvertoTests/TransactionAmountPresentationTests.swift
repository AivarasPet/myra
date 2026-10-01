import Testing
@testable import Sverto

struct TransactionAmountPresentationTests {
    @Test func ordinaryCurrencyKeepsTheSharedMoneyFormat() {
        #expect(TransactionAmountPresentation.format(-6.5, unit: "GBP") == "-£6.50")
        #expect(TransactionAmountPresentation.format(12, unit: "EUR", signed: true) == "+€12.00")
    }

    @Test func fractionalAssetsKeepEveryAvailableDigitAndTheirUnit() {
        #expect(TransactionAmountPresentation.format(-0.004, unit: "BTC") == "-0.004 BTC")
        #expect(TransactionAmountPresentation.format(0.00000001, unit: "BTC", signed: true) == "+0.00000001 BTC")
        #expect(TransactionAmountPresentation.format(1.23456789, unit: "AVGG.PN") == "1.23456789 AVGG.PN")
        #expect(TransactionAmountPresentation.format(1e-200, unit: "BTC", signed: true) == "+1e-200 BTC")
    }

    @Test func blankUnitDoesNotInventACurrency() {
        #expect(TransactionAmountPresentation.format(-12.34, unit: "") == "-12.34")
        #expect(TransactionAmountPresentation.format(0.004, unit: "") == "0.004")
    }
}
