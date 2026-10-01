import SvertoCore
import Testing
@testable import Sverto

private func currency(_ id: Int32, _ ticker: String) -> AssetItem {
    AssetItem(id: id, name: "\(ticker) name", ticker: ticker)
}

private func tickers(_ items: [AssetItem], deviceCurrencyCode: String?) -> [String] {
    CurrencyOrdering.order(items, deviceCurrencyCode: deviceCurrencyCode).map(\.ticker)
}

struct CurrencyOrderingTests {
    private let unsorted = [
        currency(1, "ZAR"),
        currency(2, "CHF"),
        currency(3, "PLN"),
        currency(4, "USD"),
        currency(5, "GBP"),
        currency(6, "AUD"),
        currency(7, "EUR"),
        currency(8, "BRL"),
    ]

    @Test func deviceCurrencyComesFirstThenPinnedThenAlphabetical() {
        #expect(tickers(unsorted, deviceCurrencyCode: "PLN") == ["PLN", "USD", "EUR", "GBP", "AUD", "CHF", "BRL", "ZAR"])
    }

    @Test func pinnedOrderIsUsdEurGbpJpyCnyInrCadAudChf() {
        let all = ["CHF", "AUD", "CAD", "INR", "CNY", "JPY", "GBP", "EUR", "USD"].enumerated().map { currency(Int32($0.offset), $0.element) }

        #expect(tickers(all, deviceCurrencyCode: nil) == ["USD", "EUR", "GBP", "JPY", "CNY", "INR", "CAD", "AUD", "CHF"])
    }

    @Test func deviceCurrencyAlreadyPinnedIsPromotedOnce() {
        #expect(tickers(unsorted, deviceCurrencyCode: "GBP") == ["GBP", "USD", "EUR", "AUD", "CHF", "BRL", "PLN", "ZAR"])
    }

    @Test func nilDeviceCurrencyFallsBackToPinnedList() {
        #expect(tickers(unsorted, deviceCurrencyCode: nil) == ["USD", "EUR", "GBP", "AUD", "CHF", "BRL", "PLN", "ZAR"])
    }

    @Test func deviceCurrencyCodeIsMatchedCaseInsensitively() {
        #expect(tickers(unsorted, deviceCurrencyCode: "pln").first == "PLN")
    }

    @Test func deviceCurrencyAbsentFromItemsIsIgnored() {
        #expect(tickers(unsorted, deviceCurrencyCode: "NOK") == tickers(unsorted, deviceCurrencyCode: nil))
    }

    @Test func restIsSortedCaseInsensitively() {
        let mixed = [currency(1, "zar"), currency(2, "Brl"), currency(3, "PLN")]

        #expect(tickers(mixed, deviceCurrencyCode: nil) == ["Brl", "PLN", "zar"])
    }

    @Test func pinnedTickersMatchCaseInsensitively() {
        let mixed = [currency(1, "zar"), currency(2, "usd")]

        #expect(tickers(mixed, deviceCurrencyCode: nil) == ["usd", "zar"])
    }

    @Test func preservesItemIdentity() {
        let ordered = CurrencyOrdering.order(unsorted, deviceCurrencyCode: "PLN")

        #expect(Set(ordered.map(\.id)) == Set(unsorted.map(\.id)))
        #expect(ordered.count == unsorted.count)
    }

    @Test func emptyInputStaysEmpty() {
        #expect(CurrencyOrdering.order([], deviceCurrencyCode: "USD").isEmpty)
    }
}
