import SvertoCore
import SwiftUI

struct GroupDetailsSection: View {
    let model: CreateTransactionGroupViewModel
    let focus: FocusState<FormField?>.Binding
    let onPickCategory: () -> Void

    var body: some View {
        let form = model.formState
        Section("Details") {
            DateChip(dateEpochSeconds: form.date) { model.updateDate($0) }
            PickerRow(
                label: "Category",
                value: form.categoryName,
                placeholder: "Choose a category",
                systemImage: "tag",
                tint: .orange,
                aiLoading: model.categories.suggestions.state == .loading,
                aiFilled: form.categoryFromAi,
                action: onPickCategory
            )
            if case let .suggested(category) = model.categories.suggestions.state {
                CategorySuggestionOfferChip(name: category.name) { model.applySuggestion() }
            }
            DescriptionField(value: form.description, prompt: "e.g. Primark Shopping", focus: focus, onChange: { model.updateDescription($0) }) {
                Task { await model.onDescriptionCommitted() }
            }
        }
    }
}
