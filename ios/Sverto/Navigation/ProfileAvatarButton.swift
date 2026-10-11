import SwiftUI

struct ProfileAvatarButton: View {
    @Environment(ShellState.self) private var shell

    var body: some View {
        Button {
            shell.presentSettings()
        } label: {
            Image(systemName: "person.crop.circle")
        }
        .accessibilityLabel("Settings")
    }
}
