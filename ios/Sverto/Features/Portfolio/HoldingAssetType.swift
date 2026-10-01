import SwiftUI

enum HoldingAssetType: Int32 {
    case currency = 1
    case stock = 2
    case bond = 3
    case mutualFund = 4
    case etf = 5
    case etc = 6
    case crypto = 7
    case realEstate = 8

    nonisolated static func systemImage(assetTypeId: Int32) -> String {
        switch HoldingAssetType(rawValue: assetTypeId) {
        case .currency: "banknote"
        case .stock: "chart.line.uptrend.xyaxis"
        case .bond: "building.columns"
        case .mutualFund, .etf, .etc: "chart.pie"
        case .crypto: "bitcoinsign.circle"
        case .realEstate: "house"
        case nil: "square.3.layers.3d"
        }
    }

    nonisolated static func tint(assetTypeId: Int32) -> Color {
        switch HoldingAssetType(rawValue: assetTypeId) {
        case .currency: .brand
        case .crypto, .realEstate: Color(.systemIndigo)
        default: Color(.systemTeal)
        }
    }
}
