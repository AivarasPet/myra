import SvertoCore
import SwiftUI

struct AssetChartSection: View {
    let model: AssetOverviewViewModel
    let onPairPickerOpen: () -> Void

    var body: some View {
        if model.isChartLoading {
            ChartSkeleton()
                .padding(.vertical, 16)
        } else if let error = model.chartError {
            ContentUnavailableView {
                Label("Couldn't load chart", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") {
                    Task { await model.retryChart() }
                }
                .buttonStyle(.bordered)
            }
        } else {
            ChartView(
                periods: model.chartPeriods,
                baseTicker: model.referenceTicker,
                selectedPeriod: periodBinding,
                headerTrailing: pairAnchor
            )
            .padding(.vertical, 16)
        }
    }

    private var periodBinding: Binding<ChartPeriod> {
        Binding(get: { model.selectedPeriod }, set: { model.selectPeriod($0) })
    }

    private var pairAnchor: (() -> AnyView)? {
        guard let detail = model.detail, let selected = model.selectedPair else { return nil }
        let label = "\(detail.displaySymbol)/\(selected.ticker)"
        let switchable = detail.pairs.count > 1
        return { AnyView(PairAnchor(label: label, switchable: switchable, action: onPairPickerOpen)) }
    }
}
