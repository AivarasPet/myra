import SwiftUI

struct WorkingDots: View {
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.tint)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(index) * 0.16),
                        value: isAnimating
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.cardFill, in: ChatBubbleShape.assistant)
        .onAppear { isAnimating = true }
        .accessibilityLabel("Myra is working")
    }
}
