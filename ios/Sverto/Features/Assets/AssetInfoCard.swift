import SvertoCore
import SwiftUI

extension AssetPairDetail {
    var hasMetadata: Bool {
        latestRate != nil || volume != nil || lastUpdated != nil || exchange != nil
    }
}

struct AssetInfoCard: View {
    let info: AssetPairDetail

    var body: some View {
        GroupedCard {
            VStack(spacing: 8) {
                if let latestRate = info.latestRate {
                    InfoLine(label: "Latest rate", value: AssetFormat.rate(latestRate))
                }
                if let volume = info.volume {
                    InfoLine(label: "Volume", value: AssetFormat.rate(volume))
                }
                if let lastUpdated = info.lastUpdated {
                    InfoLine(label: "Updated", value: AssetFormat.unixDate(lastUpdated))
                }
                if let exchange = info.exchange {
                    InfoLine(label: "Exchange", value: exchange)
                }
            }
            .padding(Layout.cardPadding)
        }
    }
}

private struct InfoLine: View {
    let label: String
    let value: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        contentLayout {
            Text(label)
                .foregroundStyle(.secondary)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 12)
            }
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var contentLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
    }
}

#Preview {
    AssetInfoCard(
        info: AssetPairDetail(
            mainTicker: "AAPL",
            mainName: "Apple Inc.",
            refTicker: "USD",
            refName: "US Dollar",
            latestRate: 189.1234,
            lastUpdated: 1_725_000_000,
            volume: 54_321_000,
            exchange: "NASDAQ"
        )
    )
    .padding()
    .background(.screenBackground)
}
