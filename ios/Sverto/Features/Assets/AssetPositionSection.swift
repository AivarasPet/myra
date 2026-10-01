import SvertoCore
import SwiftUI

struct AssetPositionSection: View {
    let overview: AssetOverviewState
    let referenceTicker: String
    let isReloading: Bool

    var body: some View {
        if overview.lots.isEmpty {
            if isReloading {
                ReloadingIndicator()
            } else {
                Text("You don't hold this asset in any account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                PositionSummary(overview: overview, referenceTicker: referenceTicker)
                SectionHeader("Positions (\(overview.lots.count) lots)")
                ForEach(Array(overview.lots.enumerated()), id: \.offset) { _, lot in
                    LotCard(lot: lot, baseTicker: referenceTicker, showAccount: true)
                }
            }
            .overlay(alignment: .top) {
                if isReloading {
                    ReloadingIndicator()
                }
            }
        }
    }
}

private struct PositionSummary: View {
    let overview: AssetOverviewState
    let referenceTicker: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("My Position · \(referenceTicker)")
            Text(Money.format(overview.value, ticker: referenceTicker))
                .font(.largeTitle.weight(.bold))
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Position value")
                .accessibilityValue(Money.format(overview.value, ticker: referenceTicker))
            MetricGrid(items: [
                MetricItem(label: "Cost Basis", value: Money.format(overview.costBasis, ticker: referenceTicker)),
                MetricItem(
                    label: "Unrealized P&L",
                    value: Money.format(overview.unrealizedGains, ticker: referenceTicker, signed: true),
                    valueColor: overview.unrealizedGains >= 0 ? .gain : .loss
                ),
                MetricItem(label: "Units Held", value: AssetFormat.units(overview.units)),
            ])
        }
    }
}

private struct ReloadingIndicator: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .accessibilityLabel("Reloading position")
    }
}
