import Foundation

nonisolated enum QuantityText {
    static func format(_ value: Double, locale: Locale) -> String {
        var style = FloatingPointFormatStyle<Double>.number.precision(.significantDigits(1...15))
        if value != 0, abs(value) < 1e-8 || abs(value) >= 1e15 {
            style = style.notation(.scientific)
        }
        return (value == 0 ? 0 : value).formatted(style.locale(locale))
    }
}
