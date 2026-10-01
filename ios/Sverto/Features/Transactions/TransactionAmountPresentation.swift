import Foundation

nonisolated enum TransactionAmountPresentation {
    static func format(_ value: Double, unit: String, signed: Bool = false) -> String {
        let raw = EditableAmount.string(value)
        let fraction = raw.split(separator: ".").dropFirst().first
        guard raw.lowercased().contains("e") || (fraction?.count ?? 0) > 2 else {
            return Money.format(value, ticker: unit, signed: signed)
        }
        let sign = signed && value > 0 ? "+" : ""
        let suffix = unit.isEmpty ? "" : " \(unit)"
        return "\(sign)\(raw)\(suffix)"
    }
}
