import SvertoCore
import SwiftUI

struct AddAccountScreen: View {
    let accountId: String?

    @Environment(AppServices.self) private var services

    var body: some View {
        AddAccountForm(store: services.store, accountId: accountId)
    }
}

private struct AddAccountForm: View {
    @State private var model: AddAccountViewModel
    @State private var isAddingIdentifier = false
    @State private var savedCount = 0
    @State private var isConfirmingDiscard = false
    @FocusState private var isNameFocused: Bool
    @Environment(ShellState.self) private var shell
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(store: AppStore, accountId: String?) {
        _model = State(initialValue: AddAccountViewModel(store: store, editingAccountId: accountId))
    }

    var body: some View {
        Group {
            if model.isLoading {
                ProgressView(model.isEditing ? "Loading account…" : "Loading account types…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.screenBackground)
            } else if let error = model.editLoadError {
                ContentUnavailableView {
                    Label("Couldn't load account", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") {
                        Task { await model.retryLoading() }
                    }
                }
                .background(.screenBackground)
            } else {
                ScrollViewReader { proxy in
                    accountForm
                        .onChange(of: model.submitState) { _, state in
                            if case .error = state {
                                proxy.scrollTo("account-save-error", anchor: .top)
                            }
                        }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(model.isEditing ? "Edit account" : "Add account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: cancel)
                    .tint(.primary)
                    .disabled(model.isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: save) {
                    if model.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(!model.canSave)
                .accessibilityLabel(model.isSaving ? "Saving account" : "Save account")
            }
        }
        .confirmationDialog("Discard changes?", isPresented: $isConfirmingDiscard, titleVisibility: .visible) {
            Button("Discard changes", role: .destructive) { shell.pop() }
            Button("Keep editing", role: .cancel) {}
        }
        .sheet(isPresented: $isAddingIdentifier) {
            AddIdentifierSheet { kind, raw in
                model.addIdentifier(kind: kind, raw: raw)
            }
        }
        .sensoryFeedback(.selection, trigger: model.selectedTypeId)
        .sensoryFeedback(.success, trigger: savedCount)
        .task { await model.start() }
        .onChange(of: model.editLoadError) { _, error in
            if let error {
                AccessibilityNotification.Announcement(error).post()
            }
        }
        .onChange(of: model.accountTypesError) { _, error in
            if let error {
                AccessibilityNotification.Announcement(error).post()
            }
        }
        .onChange(of: model.submitState) { _, state in
            if case let .error(message) = state {
                AccessibilityNotification.Announcement(message).post()
            }
        }
    }

    private var accountForm: some View {
        Form {
            if case let .error(message) = model.submitState {
                Section {
                    FormErrorRow(message: message)
                        .id("account-save-error")
                }
            }
            Section {
                TextField("Account name", text: $model.name, prompt: Text("Enter account name"))
                    .focused($isNameFocused)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .accessibilityLabel("Account name")
            } header: {
                Text("Account name")
            } footer: {
                if model.showsNameError {
                    Text("Name is required")
                        .foregroundStyle(.red)
                }
            }
            Section("Account type") {
                AccountTypePicker(
                    types: model.accountTypes,
                    isLoading: model.isLoadingTypes,
                    error: model.accountTypesError,
                    selectedTypeId: model.selectedTypeId,
                    onRetry: { Task { await model.retryAccountTypes() } }
                ) { typeId in
                    model.selectType(typeId)
                }
            }
            Section("Liquidity") {
                liquidityRow
            }
            Section("Ownership") {
                ownershipControls
            }
            AccountIdentifiersSection(
                identifiers: model.identifiers,
                onRemove: { model.removeIdentifier($0) },
                onAdd: { isAddingIdentifier = true }
            )
        }
        .disabled(model.isSaving)
    }

    private var liquidityRow: some View {
        let isSelected = model.selectedLiquidityId == AddAccountViewModel.liquidLiquidityId
        return Button {
            model.selectLiquid()
        } label: {
            HStack {
                Text("Liquid")
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var ownershipControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.ownershipPercentLabel)
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.tint)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .snappy, value: model.ownershipShare)
            Slider(value: $model.ownershipShare, in: 0.1...1.0, step: 0.1) {
                Text("Ownership share")
            } minimumValueLabel: {
                Text("10%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text("100%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .accessibilityValue(model.ownershipPercentLabel)
        }
        .padding(.vertical, 4)
    }

    private func cancel() {
        guard !model.isSaving else { return }
        isNameFocused = false
        if model.hasChanges {
            isConfirmingDiscard = true
        } else {
            shell.pop()
        }
    }

    private func save() {
        isNameFocused = false
        Task {
            if await model.save() {
                savedCount += 1
                shell.pop()
            }
        }
    }
}
