import SwiftUI

struct FormErrorRow: View {
    let message: String

    var body: some View {
        Label {
            Text(message)
                .font(.subheadline)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
        }
        .foregroundStyle(.red)
        .listRowBackground(Color.red.opacity(0.12))
    }
}
