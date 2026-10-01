import SwiftUI

struct ProminentActionButton: View {
    let title: String
    var compactTitle: String?
    var isBusy = false
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            Group {
                if isBusy {
                    ProgressView()
                        .tint(.onAccent)
                } else {
                    Text(dynamicTypeSize.isAccessibilitySize ? compactTitle ?? title : title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.onAccent)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 28)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .accessibilityLabel(title)
        .accessibilityValue(isBusy ? "In progress" : "")
    }
}
