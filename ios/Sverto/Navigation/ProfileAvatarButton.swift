import SwiftUI

struct ProfileAvatarButton: View {
    @Environment(ShellState.self) private var shell
    @Environment(ClerkGateway.self) private var clerk

    var body: some View {
        Button {
            shell.presentSettings()
        } label: {
            if let initials = clerk.initials?.uppercased(), !initials.isEmpty {
                Text(initials)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tint)
                    .frame(width: 28, height: 28)
                    .background(.tint.opacity(0.15), in: .circle)
            } else {
                Image(systemName: "person.crop.circle")
            }
        }
        .accessibilityLabel("Settings")
    }
}
