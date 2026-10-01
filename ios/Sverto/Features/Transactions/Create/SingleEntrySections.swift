import SwiftUI
import SvertoCore

struct SingleEntrySections: View {
    let mode: SingleEntryMode
    let model: CreateTransactionViewModel
    let presentation: FormPresentation
    let focus: FocusState<FormField?>.Binding

    private var form: TransactionFormState { model.formState }

    var body: some View {
        Section {
            HeroAmountInput(value: form.primaryEntry.amount, sign: mode.amountSign, autofocus: !model.mode.loadsRemotely, focus: focus) {
                model.updatePrimaryAmount($0)
            }
            TransactionFieldFeedback(message: model.validationMessage(for: .primaryAmount))
        }
        Section("Entry") {
            PickerRow(label: "Account", value: form.primaryEntry.accountName, placeholder: "Choose account", systemImage: "wallet.bifold") {
                presentation.accountTarget = .primary
            }
            TransactionFieldFeedback(message: model.validationMessage(for: .primaryAccount))
            PickerRow(label: "Asset", value: form.primaryEntry.assetDisplay, placeholder: "Search assets", systemImage: "chart.line.uptrend.xyaxis", tint: .indigo) {
                model.resetAssetSearch()
                presentation.assetTarget = .primary
            }
            TransactionFieldFeedback(message: model.validationMessage(for: .primaryAsset))
        }
        if mode.hasOriginAsset || mode.hasCategory || mode.hasDescription {
            Section("Details") {
                if mode.hasOriginAsset {
                    PickerRow(label: "Origin asset", value: form.originAssetDisplay, placeholder: "Search assets", systemImage: "chart.line.uptrend.xyaxis", tint: .indigo) {
                        model.resetAssetSearch()
                        presentation.assetTarget = .origin
                    }
                }
                if mode.hasCategory {
                    PickerRow(
                        label: "Category",
                        value: form.categoryName,
                        placeholder: "Choose a category",
                        systemImage: "tag",
                        tint: .orange,
                        aiLoading: model.categories.suggestions.state == .loading,
                        aiFilled: form.categoryFromAi
                    ) {
                        model.categories.load()
                        presentation.isCategorySearchPresented = true
                    }
                    if case let .suggested(category) = model.categories.suggestions.state {
                        CategorySuggestionOfferChip(name: category.name) { model.applySuggestion() }
                    }
                }
                if mode.hasDescription {
                    DescriptionField(value: form.description, focus: focus, onChange: { model.updateDescription($0) }) {
                        Task { await model.onDescriptionCommitted() }
                    }
                }
            }
        }
    }
}
