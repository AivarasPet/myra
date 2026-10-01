import SwiftUI

struct DualEntrySections: View {
    let mode: DualEntryMode
    let model: CreateTransactionViewModel
    let presentation: FormPresentation
    let focus: FocusState<FormField?>.Binding

    private var form: TransactionFormState { model.formState }

    private var secondaryAccountName: String {
        mode.sameAccount ? form.primaryEntry.accountName : form.secondaryEntry.accountName
    }

    var body: some View {
        if mode.sameAccount {
            Section("Account") {
                accountRow(name: form.primaryEntry.accountName, target: .primary)
            }
        }
        Section {
            if !mode.sameAccount {
                accountRow(name: form.primaryEntry.accountName, target: .primary)
            }
            assetRow(display: form.primaryEntry.assetDisplay, target: .primary)
            PanelAmountField(
                label: mode.primaryAmountLabel,
                value: form.primaryEntry.amount,
                sign: mode.primarySign,
                field: .primaryAmount,
                focus: focus
            ) { model.updatePrimaryAmount($0) }
            TransactionFieldFeedback(message: model.validationMessage(for: .primaryAmount))
        } header: {
            DirectionBadge(label: mode.primaryLabel, sign: mode.primarySign, variant: .primary)
        }
        Section {
            SwapGlyph()
        }
        Section {
            if !mode.sameAccount {
                accountRow(name: secondaryAccountName, target: .secondary)
            }
            if !mode.sameAsset {
                assetRow(display: form.secondaryEntry.assetDisplay, target: .secondary)
            }
            if !mode.sharedAmount {
                PanelAmountField(
                    label: mode.secondaryAmountLabel,
                    value: form.secondaryEntry.amount,
                    sign: mode.secondarySign,
                    field: .secondaryAmount,
                    focus: focus
                ) { model.updateSecondaryAmount($0) }
                TransactionFieldFeedback(message: model.validationMessage(for: .secondaryAmount))
            }
        } header: {
            DirectionBadge(label: mode.secondaryLabel, sign: mode.secondarySign, variant: .secondary)
        }
    }

    private func accountRow(name: String, target: AccountPickerTarget) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PickerRow(label: "Account", value: name, placeholder: "Choose account", systemImage: "wallet.bifold") {
                presentation.accountTarget = target
            }
            TransactionFieldFeedback(message: model.validationMessage(for: target == .primary ? .primaryAccount : .secondaryAccount))
        }
    }

    private func assetRow(display: String, target: AssetSearchTarget) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PickerRow(label: "Asset", value: display, placeholder: "Search assets", systemImage: "chart.line.uptrend.xyaxis", tint: .indigo) {
                model.resetAssetSearch()
                presentation.assetTarget = target
            }
            TransactionFieldFeedback(message: model.validationMessage(for: target == .primary ? .primaryAsset : .secondaryAsset))
        }
    }
}
