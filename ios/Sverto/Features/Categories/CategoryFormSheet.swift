import SvertoCore
import SwiftUI

struct CategoryFormSheet: View {
    private let existing: ManagedCategory?
    private let types: [ManagedCategoryType]
    private let onSubmit: (CategoryFormResult) async throws -> Void

    @State private var name: String
    @State private var icon: String
    @State private var typeId: Int32?
    @State private var initialTypeId: Int32?
    @State private var isIconPickerPresented = false
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var isConfirmingDiscard = false
    @FocusState private var isNameFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(existing: ManagedCategory?, types: [ManagedCategoryType], onSubmit: @escaping (CategoryFormResult) async throws -> Void) {
        self.existing = existing
        self.types = types
        self.onSubmit = onSubmit
        _name = State(initialValue: existing?.name ?? "")
        _icon = State(initialValue: existing?.icon ?? LucideCatalog.fallbackName)
        _typeId = State(initialValue: existing?.categoryTypeId ?? types.first?.id)
        _initialTypeId = State(initialValue: existing?.categoryTypeId ?? types.first?.id)
    }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSave: Bool { !trimmedName.isEmpty && typeId != nil }

    private var hasChanges: Bool {
        trimmedName != (existing?.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            || icon != (existing?.icon ?? LucideCatalog.fallbackName)
            || typeId != initialTypeId
    }

    var body: some View {
        NavigationStack {
            Form {
                if let saveError {
                    Section {
                        FormErrorRow(message: saveError)
                    }
                }
                Section {
                    HStack(spacing: 16) {
                        Button {
                            isIconPickerPresented = true
                        } label: {
                            CategoryIconTile(icon: icon, size: 56)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Icon: \(icon.replacingOccurrences(of: "-", with: " "))")
                        .accessibilityHint("Choose an icon")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            TextField("Name", text: $name)
                                .focused($isNameFocused)
                                .textInputAutocapitalization(.sentences)
                                .submitLabel(.done)
                                .onSubmit(save)
                        }
                    }
                }
                Section {
                    Picker("Type", selection: $typeId) {
                        if typeId == nil {
                            Text("Choose a type").tag(Int32?.none)
                        }
                        ForEach(types, id: \.id) { type in
                            Text(type.name).tag(Int32?.some(type.id))
                        }
                    }
                    .pickerStyle(.menu)
                } footer: {
                    if types.isEmpty {
                        Text("No types available")
                    }
                }
            }
            .disabled(isSaving)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(existing == nil ? "New category" : "Edit category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                        .tint(.primary)
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(!canSave || isSaving)
                    .accessibilityLabel(isSaving ? "Saving category" : "Save category")
                }
            }
            .onChange(of: name) { _, newValue in
                if newValue.count > 100 {
                    name = String(newValue.prefix(100))
                }
            }
            .onAppear {
                if existing == nil { isNameFocused = true }
            }
            .sheet(isPresented: $isIconPickerPresented) {
                LucideIconPickerSheet(selected: icon) { icon = $0 }
            }
            .confirmationDialog("Discard changes?", isPresented: $isConfirmingDiscard, titleVisibility: .visible) {
                Button("Discard changes", role: .destructive) { dismiss() }
                Button("Keep editing", role: .cancel) {}
            }
        }
        .interactiveDismissDisabled(hasChanges || isSaving)
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large])
    }

    private func cancel() {
        guard !isSaving else { return }
        isNameFocused = false
        if hasChanges {
            isConfirmingDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        guard let typeId, canSave, !isSaving else { return }
        isNameFocused = false
        isSaving = true
        saveError = nil
        let result = CategoryFormResult(id: existing?.id, name: trimmedName, icon: icon, typeId: typeId)
        Task {
            defer { isSaving = false }
            do {
                try await onSubmit(result)
                dismiss()
            } catch {
                saveError = error.friendlyMessage
                AccessibilityNotification.Announcement(error.friendlyMessage).post()
            }
        }
    }
}
