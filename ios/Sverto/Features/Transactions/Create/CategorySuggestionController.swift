import Foundation
import Observation
import SvertoCore

enum SuggestionState: Equatable {
    case idle
    case loading
    case suggested(CategoryItem)
}

@Observable
final class CategorySuggestionController {
    private(set) var state: SuggestionState = .idle

    var isAvailable: Bool { availabilityCheck() }

    private let availabilityCheck: () -> Bool
    private let loadCategories: () async throws -> [CategoryItem]
    private let suggest: (String, [CategoryItem]) async throws -> CategoryItem?
    private var cachedCategories: [CategoryItem] = []
    private var lastCommittedText: String?
    private var generation = 0

    init(
        isAvailable: @escaping () -> Bool,
        loadCategories: @escaping () async throws -> [CategoryItem],
        suggest: @escaping (String, [CategoryItem]) async throws -> CategoryItem?
    ) {
        availabilityCheck = isAvailable
        self.loadCategories = loadCategories
        self.suggest = suggest
    }

    convenience init(store: AppStore) {
        self.init(
            isAvailable: { CategorySuggester.isAvailable },
            loadCategories: { try await store.getAllCategories() },
            suggest: { description, categories in await CategorySuggester.suggest(description: description, categories: categories) }
        )
    }

    func onDescriptionChanged(_ text: String) {
        if case .suggested = state, text.trimmingCharacters(in: .whitespacesAndNewlines) != lastCommittedText {
            state = .idle
        }
    }

    func markCommitted(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        lastCommittedText = trimmed.isEmpty ? nil : trimmed
        generation += 1
        state = .idle
    }

    @discardableResult
    func suggestFor(text: String) async -> CategoryItem? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != lastCommittedText, isAvailable else { return nil }
        lastCommittedText = trimmed
        state = .loading
        generation += 1
        let current = generation
        defer {
            if generation == current { state = .idle }
        }
        do {
            let categories = try await ensureCategories()
            let result = categories.isEmpty ? nil : try await suggest(trimmed, categories)
            return generation == current ? result : nil
        } catch is CancellationError {
            return nil
        } catch {
            if lastCommittedText == trimmed { lastCommittedText = nil }
            return nil
        }
    }

    func offer(_ category: CategoryItem) {
        state = .suggested(category)
    }

    func takeSuggestion() -> CategoryItem? {
        guard case let .suggested(category) = state else { return nil }
        state = .idle
        return category
    }

    func reset() {
        generation += 1
        state = .idle
    }

    private func ensureCategories() async throws -> [CategoryItem] {
        if cachedCategories.isEmpty {
            cachedCategories = try await loadCategories()
        }
        return cachedCategories
    }
}
