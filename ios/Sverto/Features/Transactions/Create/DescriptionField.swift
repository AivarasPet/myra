import SwiftUI

struct DescriptionField: View {
    let value: String
    var prompt: String? = nil
    let focus: FocusState<FormField?>.Binding
    let onChange: (String) -> Void
    let onCommit: () -> Void

    @State private var isEditing = false

    private var text: Binding<String> {
        Binding(get: { value }, set: { onChange($0) })
    }

    var body: some View {
        HStack(alignment: .top, spacing: Layout.rowSpacing) {
            Image(systemName: "text.alignleft")
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Description")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                TextField("Description", text: text, prompt: Text(prompt ?? "Add a description"), axis: .vertical)
                    .lineLimit(2...6)
                    .focused(focus, equals: .description)
            }
        }
        .onChange(of: focus.wrappedValue == .description) { _, focused in
            if focused {
                isEditing = true
            } else if isEditing {
                isEditing = false
                onCommit()
            }
        }
    }
}
