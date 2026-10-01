import Foundation
import Observation
import SvertoCore

@Observable
final class AssetOverviewViewModel {
    private(set) var isLoading = true
    private(set) var overview: AssetOverviewState?
    private(set) var detail: AssetDetail?
    private(set) var selectedPairId: Int32?
    private(set) var pairInfo: AssetPairDetail?
    private(set) var selectedPeriod = ChartPeriod.defaultSelection
    private(set) var chartByPeriod: [ChartPeriod: [ChartPoint]] = [:]
    private(set) var chartErrors: [ChartPeriod: String] = [:]
    private(set) var isUserAsset = false
    private(set) var isReloading = false
    private(set) var lastError: AssetErrorEvent?

    private let store: AppStore
    private var assetId: Int32 = 0
    private var bridge: AssetOverviewObserverBridge?
    private var chartGeneration = 0

    init(store: AppStore) {
        self.store = store
    }

    var pairs: [AssetPairRef] { detail?.pairs ?? [] }

    var selectedPair: AssetPairRef? { pair(selectedPairId) }

    var title: String { detail?.displaySymbol ?? overview?.ticker ?? "" }

    var subtitle: String { detail?.name ?? overview?.name ?? "" }

    var referenceTicker: String { selectedPair?.ticker ?? overview?.priceTicker ?? "" }

    var isChartLoading: Bool {
        isLoading || (selectedPairId != nil && chartByPeriod[selectedPeriod] == nil && chartError == nil)
    }

    var chartError: String? { chartErrors[selectedPeriod] }

    var chartPeriods: [ChartPeriodData] {
        ChartPeriod.allCases.map { ChartPeriodData(period: $0.rawValue, points: chartByPeriod[$0] ?? []) }
    }

    func start() {
        guard bridge == nil else { return }
        let bridge = AssetOverviewObserverBridge { [weak self] state in
            Task { @MainActor [weak self] in self?.handleOverview(state) }
        }
        self.bridge = bridge
        store.observeAssetOverview(observer: bridge)
    }

    func stop() {
        guard bridge != nil else { return }
        bridge = nil
        store.unobserveAssetOverview()
    }

    func load(assetId: Int32, userAsset: Bool) async {
        let alreadyLoaded = assetId == self.assetId && userAsset == isUserAsset && detail != nil
        if alreadyLoaded { return }
        self.assetId = assetId
        await reload(userAsset: userAsset)
    }

    func selectPair(_ referenceId: Int32) {
        chartGeneration += 1
        selectedPairId = referenceId
        pairInfo = nil
        chartByPeriod = [:]
        chartErrors = [:]
        isReloading = true
        Task { await loadPairInfo(referenceId) }
        Task { await loadRates(selectedPeriod) }
        let store = self.store
        let assetId = self.assetId
        Task { await store.loadAssetOverview(assetId: assetId, referenceAssetId: referenceId) }
    }

    func selectPeriod(_ period: ChartPeriod) {
        selectedPeriod = period
        if chartByPeriod[period] == nil {
            Task { await loadRates(period) }
        }
    }

    func retryChart() async {
        await loadRates(selectedPeriod)
    }

    func addRate(referenceId: Int32, date: Int64, rate: Double) async throws {
        let targetAssetId = assetId
        try await store.addUserAssetRate(assetId: targetAssetId, referenceId: referenceId, date: date, rate: rate)
        guard assetId == targetAssetId, selectedPairId == referenceId else { return }
        selectPair(referenceId)
    }

    func addPair(_ referenceId: Int32) async {
        do {
            try await store.addUserAssetPair(assetId: assetId, referenceId: referenceId)
            await reload(userAsset: isUserAsset)
        } catch {
            report(error)
        }
    }

    func delete() async -> Bool {
        do {
            try await store.deleteUserAsset(assetId: assetId)
            return true
        } catch {
            report(error)
            return false
        }
    }

    private func reload(userAsset: Bool) async {
        isLoading = true
        overview = nil
        detail = nil
        selectedPairId = nil
        pairInfo = nil
        selectedPeriod = ChartPeriod.defaultSelection
        chartByPeriod = [:]
        chartErrors = [:]
        isUserAsset = userAsset
        isReloading = false
        do {
            let loaded = try await store.getAssetDetail(assetId: assetId, userAsset: userAsset)
            let defaultPair = loaded.basePairId ?? loaded.pairs.first?.assetId
            detail = loaded
            isLoading = false
            selectedPairId = defaultPair
            if let defaultPair {
                selectPair(defaultPair)
            }
        } catch {
            isLoading = false
            report(error)
        }
    }

    private func handleOverview(_ state: AssetOverviewState) {
        guard assetId != 0, state.assetId == assetId else { return }
        overview = state
        isLoading = false
        if !state.isLoading {
            isReloading = false
        }
        if let error = state.error {
            lastError = AssetErrorEvent(message: error)
        }
    }

    private func loadPairInfo(_ referenceId: Int32) async {
        let generation = chartGeneration
        do {
            let info: AssetPairDetail
            if let converted = pair(referenceId), converted.converted {
                let rate = try await store.getAssetPairConverted(assetId: assetId, referenceId: referenceId, userAsset: isUserAsset)
                info = AssetPairDetail(
                    mainTicker: detail?.displaySymbol ?? "",
                    mainName: detail?.name ?? "",
                    refTicker: converted.ticker,
                    refName: converted.name,
                    latestRate: rate.latestRate,
                    lastUpdated: rate.lastUpdated,
                    volume: nil,
                    exchange: nil
                )
            } else {
                info = try await store.getAssetPair(assetId: assetId, referenceId: referenceId, userAsset: isUserAsset)
            }
            guard generation == chartGeneration else { return }
            pairInfo = info
        } catch {
            guard generation == chartGeneration else { return }
            report(error)
        }
    }

    private func loadRates(_ period: ChartPeriod) async {
        guard let referenceId = selectedPairId else { return }
        let generation = chartGeneration
        let range = period.apiRange
        chartErrors[period] = nil
        do {
            let points: [ChartPoint]
            if pair(referenceId)?.converted == true {
                points = try await store.getAssetPairConvertedRates(assetId: assetId, referenceId: referenceId, range: range, userAsset: isUserAsset)
            } else {
                points = try await store.getAssetPairRates(assetId: assetId, referenceId: referenceId, range: range, userAsset: isUserAsset)
            }
            guard generation == chartGeneration else { return }
            chartByPeriod[period] = points
        } catch {
            guard generation == chartGeneration else { return }
            chartErrors[period] = error.friendlyMessage
            report(error)
        }
    }

    private func pair(_ referenceId: Int32?) -> AssetPairRef? {
        guard let referenceId else { return nil }
        return detail?.pairs.first { $0.assetId == referenceId }
    }

    private func report(_ error: Error) {
        lastError = AssetErrorEvent(error)
    }
}
