import Foundation
import Observation
import SvertoCore

@Observable
final class AiUsageViewModel {
    private(set) var usage: AiUsage?
    private(set) var errorMessage: String?

    private let store: AppStore

    init(store: AppStore) {
        self.store = store
    }

    func load() async {
        errorMessage = nil
        do {
            usage = try await store.getAiUsage()
        } catch {
            errorMessage = error.friendlyMessage
        }
    }
}
