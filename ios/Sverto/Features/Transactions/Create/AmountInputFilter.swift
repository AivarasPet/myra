import Foundation

nonisolated enum AmountInputFilter {
    static func filter(_ input: String, allowNegative: Bool) -> String {
        let normalized = input.replacingOccurrences(of: ",", with: ".")
        let prefix = allowNegative
            ? normalized.firstMatch(of: /^-?\d*\.?\d*/).map { String($0.output) }
            : normalized.firstMatch(of: /^\d*\.?\d*/).map { String($0.output) }
        return prefix ?? ""
    }
}
