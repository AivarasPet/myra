import SwiftUI

struct StreamingCaret: View {
    @State private var isVisible = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.tint)
            .frame(width: 9, height: 18)
            .opacity(isVisible ? 1 : 0)
            .padding(.leading, 3)
            .animation(reduceMotion ? nil : .linear(duration: 0.5).repeatForever(autoreverses: true), value: isVisible)
            .onAppear { isVisible = false }
            .accessibilityHidden(true)
    }
}
