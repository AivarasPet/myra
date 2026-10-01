nonisolated enum ChartPeriod: String, CaseIterable, Hashable {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case year = "1Y"
    case all = "ALL"

    static let defaultSelection: ChartPeriod = .month

    var isIntraday: Bool { self == .day }

    var apiRange: String {
        switch self {
        case .day: "1d"
        case .week: "1w"
        case .month: "1m"
        case .threeMonths: "3m"
        case .sixMonths: "6m"
        case .year: "1y"
        case .all: "all"
        }
    }
}
