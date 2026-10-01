import SvertoCore
import SwiftUI

struct AssetTypeDropdown: View {
    let assetTypes: [AssetTypeOption]
    @Binding var selectedId: Int32?

    var body: some View {
        Picker("Type", selection: $selectedId) {
            if selectedId == nil {
                Text("Choose a type").tag(Int32?.none)
            }
            ForEach(assetTypes, id: \.id) { type in
                Text(type.name).tag(Int32?.some(type.id))
            }
        }
        .pickerStyle(.menu)
    }
}

#Preview {
    @Previewable @State var selected: Int32? = 1
    Form {
        AssetTypeDropdown(
            assetTypes: [AssetTypeOption(id: 1, name: "Stock"), AssetTypeOption(id: 2, name: "Crypto")],
            selectedId: $selected
        )
    }
}
