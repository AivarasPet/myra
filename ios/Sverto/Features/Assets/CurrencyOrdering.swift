import Foundation
import SvertoCore

enum CurrencyOrdering {
    private static let pinnedCodes = ["USD", "EUR", "GBP", "JPY", "CNY", "INR", "CAD", "AUD", "CHF"]

    static func order(_ items: [AssetItem]) -> [AssetItem] {
        order(items, deviceCurrencyCode: Locale.current.currency?.identifier)
    }

    static func order(_ items: [AssetItem], deviceCurrencyCode: String?) -> [AssetItem] {
        var seen = Set<String>()
        let priority = ([deviceCurrencyCode?.uppercased()].compactMap { $0 } + pinnedCodes)
            .filter { seen.insert($0).inserted }
        let byTicker = Dictionary(items.map { ($0.ticker.uppercased(), $0) }, uniquingKeysWith: { _, last in last })
        let pinned = priority.compactMap { byTicker[$0] }
        let pinnedIds = Set(pinned.map(\.id))
        let rest = items
            .filter { !pinnedIds.contains($0.id) }
            .sorted { $0.ticker.uppercased() < $1.ticker.uppercased() }
        return pinned + rest
    }
}
