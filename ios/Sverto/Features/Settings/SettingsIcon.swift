import SwiftUI

struct SettingsIcon: View {
    let systemImage: String
    var tint: Color = .accentColor
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 29

    var body: some View {
        Image(systemName: systemImage)
            .font(.callout.weight(.semibold))
            .foregroundStyle(Color.onAccent)
            .frame(width: size, height: size)
            .background(tint, in: .rect(cornerRadius: size * 0.24))
            .accessibilityHidden(true)
    }
}
