import SwiftUI

struct AuthHeader<Symbol: View>: View {
    let title: String
    let description: String
    var tint: Color = .accentColor
    @ViewBuilder let symbol: () -> Symbol

    var body: some View {
        VStack(spacing: 20) {
            symbol()
                .font(.largeTitle.weight(.medium))
                .imageScale(.large)
                .foregroundStyle(tint)
                .frame(width: 104, height: 104)
                .background(tint.opacity(0.15), in: .rect(cornerRadius: 32, style: .continuous))
                .accessibilityHidden(true)
            VStack(spacing: 8) {
                Text(title)
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

extension AuthHeader where Symbol == Image {
    init(title: String, description: String, systemImage: String, tint: Color = .accentColor) {
        self.init(title: title, description: description, tint: tint) {
            Image(systemName: systemImage)
        }
    }
}
