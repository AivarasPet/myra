import Foundation
import Observation
import SvertoCore

@Observable
final class CustomCategoriesViewModel {
    private(set) var state = CategoriesState(isLoading: true, error: nil, categories: [], types: [])

    private let store: AppStore
    private var bridge: CategoriesObserverBridge?

    init(store: AppStore) {
        self.store = store
    }

    func start() async {
        observeIfNeeded()
        await store.loadCategories()
    }

    func stop() {
        guard bridge != nil else { return }
        bridge = nil
        store.unobserveCategories()
    }

    func refresh() async {
        await store.refreshCategories()
    }

    func createCategory(name: String, icon: String, typeId: Int32) async throws {
        try await store.createCategory(name: name, icon: icon, typeId: typeId)
    }

    func updateCategory(id: Int32, name: String, icon: String, typeId: Int32) async throws {
        try await store.updateCategory(id: id, name: name, icon: icon, typeId: typeId)
    }

    func deleteCategory(id: Int32) async throws {
        try await store.deleteCategory(id: id)
    }

    func createType(name: String) async throws {
        try await store.createCategoryType(name: name)
    }

    func updateType(id: Int32, name: String) async throws {
        try await store.updateCategoryType(id: id, name: name)
    }

    func deleteType(id: Int32) async throws {
        try await store.deleteCategoryType(id: id)
    }

    private func observeIfNeeded() {
        guard bridge == nil else { return }
        let bridge = CategoriesObserverBridge { [weak self] state in
            Task { @MainActor [weak self] in self?.state = state }
        }
        self.bridge = bridge
        store.observeCategories(observer: bridge)
    }
}
