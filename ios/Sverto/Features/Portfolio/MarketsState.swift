import Foundation
import SvertoCore

struct MarketsState: Equatable {
    var query = ""
    var items: [AssetSummary] = []
    var total = 0
    var isLoading = false
    var isLoadingMore = false

    var isQueryBlank: Bool { query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var hasMore: Bool { items.count < total }
}
