import SvertoCore

nonisolated enum AssetSearchState {
    case idle
    case loading
    case results([AssetItem])
    case failed(String)
}
