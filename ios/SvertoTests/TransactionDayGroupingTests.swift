import Foundation
import SvertoCore
import Testing
@testable import Sverto

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    return calendar
}()

private func day(_ year: Int, _ month: Int, _ day: Int) throws -> Date {
    try #require(calendar.date(from: DateComponents(year: year, month: month, day: day)))
}

private func item(_ id: String, _ date: Date) -> TransactionListItem {
    TransactionListItem(
        id: id,
        date: Int64(date.timeIntervalSince1970),
        description: "tx \(id)",
        transactionType: "purchase",
        typeLabel: "Purchase",
        amountDisplay: "-10.00 EUR",
        secondaryAmountDisplay: nil,
        accountName: "Current",
        secondaryAccountName: nil,
        assetDisplay: "EUR",
        categoryName: "Groceries",
        categoryId: 25,
        categoryIcon: "shopping-cart",
        visibility: .default,
        isGroup: false,
        groupSize: 0,
        children: []
    )
}

struct TransactionDayGroupingTests {
    @Test func labelsTodayYesterdayAndAbsoluteDates() throws {
        let today = try day(2026, 7, 26)
        let items = [
            item("1", today),
            item("2", try day(2026, 7, 25)),
            item("3", try day(2026, 7, 19)),
        ]

        let grouped = TransactionDayGrouping.group(items, today: today, calendar: calendar)

        #expect(grouped.map(\.label) == ["Today", "Yesterday", "Jul 19, 2026"])
    }

    @Test func collapsesSameDayItemsIntoOneBucket() throws {
        let today = try day(2026, 7, 26)
        let items = [
            item("1", today),
            item("2", today),
            item("3", try day(2026, 7, 25)),
        ]

        let grouped = TransactionDayGrouping.group(items, today: today, calendar: calendar)

        #expect(grouped.count == 2)
        #expect(grouped[0].transactions.map(\.id) == ["1", "2"])
        #expect(grouped[1].transactions.map(\.id) == ["3"])
    }

    @Test func returnsEmptyListForEmptyInput() throws {
        let today = try day(2026, 7, 26)

        let grouped = TransactionDayGrouping.group([], today: today, calendar: calendar)

        #expect(grouped.isEmpty)
    }

    @Test func labelsYearBoundaryDatesWithFullYear() throws {
        let today = try day(2026, 7, 26)
        let items = [
            item("1", try day(2025, 12, 31)),
            item("2", try day(2026, 1, 1)),
        ]

        let grouped = TransactionDayGrouping.group(items, today: today, calendar: calendar)

        #expect(grouped.map(\.label) == ["Dec 31, 2025", "Jan 1, 2026"])
    }
}
