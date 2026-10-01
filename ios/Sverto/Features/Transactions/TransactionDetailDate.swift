import Foundation

enum TransactionDetailDate {
    nonisolated static func string(epochSeconds: Int64) -> String {
        DateText.date(fromUnix: epochSeconds).formatted(
            .dateTime.weekday(.wide).month(.abbreviated).day().year().hour().minute()
                .locale(DateText.androidParityLocale)
        )
    }
}
