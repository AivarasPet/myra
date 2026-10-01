import SwiftUI

extension View {
    func aiThinkingBorder(active: Bool, cornerRadius: CGFloat = Layout.tileRadius) -> some View {
        modifier(AiThinkingBorder(active: active, cornerRadius: cornerRadius))
    }
}

private struct AiThinkingBorder: ViewModifier {
    let active: Bool
    let cornerRadius: CGFloat
    @State private var pulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if active {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(colors: [.brand, .indigo], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 2
                        )
                        .opacity(pulsing ? 1 : 0.35)
                        .onAppear {
                            guard !reduceMotion else { return }
                            withAnimation(.linear(duration: 0.65).repeatForever(autoreverses: true)) {
                                pulsing = true
                            }
                        }
                        .onDisappear { pulsing = false }
                        .accessibilityLabel("Suggesting a category")
                }
            }
    }
}

struct CategorySuggestionOfferChip: View {
    let name: String
    let action: () -> Void

    init(name: String, action: @escaping () -> Void) {
        self.name = name
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label("\(name)?", systemImage: "sparkles")
                .font(.subheadline.weight(.medium))
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .tint(.brand)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
        .accessibilityLabel("Apply suggested category \(name)")
    }
}
