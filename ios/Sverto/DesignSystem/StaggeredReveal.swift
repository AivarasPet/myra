import SwiftUI

struct StaggeredReveal: ViewModifier {
    let isRevealed: Bool
    let index: Int
    let reduceMotion: Bool

    private var isShown: Bool { isRevealed || reduceMotion }

    func body(content: Content) -> some View {
        content
            .opacity(isShown ? 1 : 0)
            .offset(y: isShown ? 0 : 24)
            .animation(reduceMotion ? nil : .spring(duration: 0.45).delay(Double(index) * 0.08), value: isRevealed)
    }
}
