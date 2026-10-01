import Foundation
import Observation
import SvertoCore

nonisolated protocol CategorizedForm {
    var description: String { get set }
    var categoryId: Int32? { get set }
    var categoryName: String { get set }
    var categoryFromAi: Bool { get set }
}

extension CategorizedForm {
    mutating func setCategory(_ category: CategoryItem, fromAi: Bool) {
        categoryId = category.id
        categoryName = category.name
        categoryFromAi = fromAi
    }
}

@Observable
final class CategoryFieldController {
    private(set) var results: [CategoryItem] = []
    private(set) var isLoading = false
    let suggestions: CategorySuggestionController

    private let store: AppStore
    private var all: [CategoryItem] = []
    private var loadTask: Task<Void, Never>?

    init(store: AppStore) {
        self.store = store
        suggestions = CategorySuggestionController(store: store)
        CategorySuggester.prefetch()
    }

    func load() {
        loadTask?.cancel()
        loadTask = Task { [store] in
            isLoading = true
            defer { if !Task.isCancelled { isLoading = false } }
            guard let loaded = try? await store.getAllCategories(), !Task.isCancelled else { return }
            all = loaded
            results = loaded
        }
    }

    func filter(_ query: String) {
        results = query.isBlank ? all : all.filter { $0.name.range(of: query, options: .caseInsensitive) != nil }
    }

    func updateDescription<Form: CategorizedForm>(_ text: String, in form: inout Form) {
        suggestions.onDescriptionChanged(text)
        form.description = text
    }

    func select<Form: CategorizedForm>(_ category: CategoryItem, in form: inout Form) {
        suggestions.reset()
        form.setCategory(category, fromAi: false)
        results = []
    }

    func applySuggestion<Form: CategorizedForm>(in form: inout Form) {
        guard let category = suggestions.takeSuggestion() else { return }
        form.setCategory(category, fromAi: true)
    }

    func commitDescription<Owner: AnyObject, Form: CategorizedForm>(of owner: Owner, at form: ReferenceWritableKeyPath<Owner, Form>) async {
        let committed = owner[keyPath: form].description
        guard let suggested = await suggestions.suggestFor(text: committed), owner[keyPath: form].description == committed else { return }
        if owner[keyPath: form].categoryId == nil || owner[keyPath: form].categoryFromAi {
            owner[keyPath: form].setCategory(suggested, fromAi: true)
        } else if owner[keyPath: form].categoryId != suggested.id {
            suggestions.offer(suggested)
        }
    }
}
