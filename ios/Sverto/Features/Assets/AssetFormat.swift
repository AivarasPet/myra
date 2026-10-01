import Foundation

enum AssetFormat {
    nonisolated static func rate(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(4)).locale(DateText.androidParityLocale))
    }

    nonisolated static func unixDate(_ seconds: Int64) -> String {
        DateText.mediumDate(epochSeconds: seconds)
    }

    nonisolated static func units(_ value: Double) -> String {
        QuantityText.format(value, locale: DateText.androidParityLocale)
    }
}
