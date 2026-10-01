import SvertoCore
import SwiftUI

struct LotCard: View {
    private let lot: LotItem
    private let baseTicker: String
    private let showAccount: Bool

    init(lot: LotItem, baseTicker: String, showAccount: Bool = false) {
        self.lot = lot
        self.baseTicker = baseTicker
        self.showAccount = showAccount
    }

    private var isClosed: Bool { lot.unitsRemaining <= 0 }
    private var gainColor: Color { lot.gainPercent >= 0 ? .gain : .loss }
    private var realizedColor: Color { lot.realizedGains >= 0 ? .gain : .loss }
    private var buyDate: String { DateText.mediumDate(epochSeconds: lot.buyDate) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showAccount {
                Text(lot.accountName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            LotMetadataRow {
                Text("\(AssetFormat.units(lot.unitsRemaining)) of \(AssetFormat.units(lot.unitsBought)) units held")
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(isClosed ? .secondary : .primary)
            } trailing: {
                if !isClosed {
                    Text(PercentText.format(lot.gainPercent / 100))
                        .font(.subheadline.weight(.medium))
                        .monospacedDigit()
                        .foregroundStyle(gainColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(gainColor.opacity(0.12), in: .rect(cornerRadius: 6))
                }
            }
            LotMetadataRow {
                Text(isClosed ? "\(buyDate) · CLOSED" : "Bought \(buyDate)")
            } trailing: {
                Text("@ \(Money.format(lot.buyPricePerUnit, ticker: baseTicker))/unit")
                    .monospacedDigit()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            if !isClosed {
                LotMetadataRow {
                    Text("Unrealized: \(Money.format(lot.unrealizedGains, ticker: baseTicker, signed: true))")
                        .fontWeight(.medium)
                        .foregroundStyle(gainColor)
                } trailing: {
                    Text("Value: \(Money.format(lot.currentValue, ticker: baseTicker))")
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
                .monospacedDigit()
            }
            if lot.unitsSold > 0 {
                Text("Realized: \(Money.format(lot.realizedGains, ticker: baseTicker, signed: true)) · \(AssetFormat.units(lot.unitsSold)) sold")
                    .font(.footnote.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(realizedColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.cardFill, in: .rect(cornerRadius: Layout.cardRadius))
        .accessibilityElement(children: .combine)
    }
}

private struct LotMetadataRow<Leading: View, Trailing: View>: View {
    @ViewBuilder let leading: Leading
    @ViewBuilder let trailing: Trailing
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            stacked
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    leading.fixedSize()
                    Spacer(minLength: 0)
                    trailing.fixedSize()
                }
                stacked
            }
        }
    }

    private var stacked: some View {
        VStack(alignment: .leading, spacing: 4) {
            leading
            trailing
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
