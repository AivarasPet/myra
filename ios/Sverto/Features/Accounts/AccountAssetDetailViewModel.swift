import Foundation
import Observation
import SvertoCore

@Observable
final class AccountAssetDetailViewModel {
    private(set) var state = AssetDetailState(
        isLoading: true,
        error: nil,
        assetId: 0,
        ticker: "",
        name: "",
        units: 0,
        value: 0,
        costBasis: 0,
        unrealizedGains: 0,
        totalFees: 0,
        currentPrice: 0,
        chartData: [],
        lots: [],
        baseTicker: "",
        priceTicker: "",
        supportsBaseConversion: false,
        baseChartData: []
    )
    private(set) var showsBaseCurrency = false
    private(set) var isBaseChartLoading = false

    private let store: AppStore
    private let accountId: String
    private let assetId: Int32
    private var bridge: AssetDetailObserverBridge?
    private var hasLoaded = false

    init(store: AppStore, accountId: String, assetId: Int32) {
        self.store = store
        self.accountId = accountId
        self.assetId = assetId
    }

    var activeChartData: [ChartPeriodData] {
        showsBaseCurrency ? state.baseChartData : state.chartData
    }

    var activeTicker: String {
        showsBaseCurrency ? state.baseTicker : state.priceTicker
    }

    func start() async {
        observeIfNeeded()
        guard !hasLoaded else { return }
        hasLoaded = true
        await store.loadAssetDetail(accountId: accountId, assetId: assetId)
    }

    func stop() {
        guard bridge != nil else { return }
        bridge = nil
        store.unobserveAssetDetail()
    }

    func selectCurrency(showBase: Bool) async {
        showsBaseCurrency = showBase
        guard showBase, state.baseChartData.isEmpty, !isBaseChartLoading else { return }
        isBaseChartLoading = true
        await store.loadAssetDetailBaseChart()
        isBaseChartLoading = false
    }

    private func observeIfNeeded() {
        guard bridge == nil else { return }
        let bridge = AssetDetailObserverBridge { [weak self] state in
            Task { @MainActor [weak self] in self?.state = state }
        }
        self.bridge = bridge
        store.observeAssetDetail(observer: bridge)
    }
}
