import SwiftUI

extension View {
    func settingsSheet() -> some View {
        modifier(SettingsSheetModifier())
    }
}

private struct SettingsSheetModifier: ViewModifier {
    @Environment(ShellState.self) private var shell
    @Environment(ToastCenter.self) private var toasts

    func body(content: Content) -> some View {
        @Bindable var shell = shell
        content.sheet(isPresented: $shell.isSettingsPresented, onDismiss: { shell.dismissSettings() }) {
            NavigationStack(path: $shell.settingsPath) {
                SettingsScreen()
                    .offlineBannerInset()
                    .navigationDestination(for: AppRoute.self) { RouteDestination(route: $0) }
            }
            .toastHost(toasts)
        }
    }
}
