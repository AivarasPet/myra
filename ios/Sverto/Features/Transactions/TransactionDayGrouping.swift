import Foundation
import SvertoCore

struct TransactionDayGroup: Identifiable, Equatable {
    let label: String
    let transactions: [TransactionListItem]

    var id: String { label }
}

enum TransactionDayGrouping {
    nonisolated static func group(
        _ transactions: [TransactionListItem],
        today: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent
    ) -> [TransactionDayGroup] {
        var labelsInOrder: [String] = []
        var buckets: [String: [TransactionListItem]] = [:]
        for transaction in transactions {
            let label = DateText.dayHeader(epochSeconds: transaction.date, today: today, calendar: calendar)
            if buckets[label] == nil {
                labelsInOrder.append(label)
            }
            buckets[label, default: []].append(transaction)
        }
        return labelsInOrder.map { TransactionDayGroup(label: $0, transactions: buckets[$0] ?? []) }
    }
}
