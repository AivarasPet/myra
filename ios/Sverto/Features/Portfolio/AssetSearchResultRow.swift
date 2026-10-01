import SwiftUI
import SvertoCore

struct AssetSearchResultRow: View {
    let asset: AssetSummary

    private var supportingText: String {
        asset.assetType.trimmingCharacters(in: .whitespaces).isEmpty ? asset.name : "\(asset.name) · \(asset.assetType)"
    }

    var body: some View {
        AssetListRow(ticker: asset.ticker, name: asset.name, supportingText: supportingText)
    }
}
