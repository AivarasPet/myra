import SwiftUI

struct ToolbarSearch: ViewModifier {
    @Binding var text: String
    @Binding var isPresented: Bool
    let prompt: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .background {
            ToolbarSearchController(text: $text, isPresented: isPresented, prompt: prompt) {
                withAnimation(reduceMotion ? nil : .default) {
                    isPresented = false
                    text = ""
                }
            }
            .frame(width: 0, height: 0)
        }
    }
}
