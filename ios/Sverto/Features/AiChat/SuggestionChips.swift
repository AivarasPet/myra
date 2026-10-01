import SwiftUI

struct SuggestionChips: View {
    let onSuggestion: (String) -> Void

    @State private var hasAppeared = false
    @ScaledMetric(relativeTo: .largeTitle) private var heroGlyphSize: CGFloat = 64
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let suggestions = [
        "What's my spending this month?",
        "How are my investments performing?",
        "Show my recent transactions",
        "What's my biggest expense category?",
        "How much did I save last month?",
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Image(systemName: "sparkles")
                        .font(.system(size: heroGlyphSize))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    Text("Ask Myra about your finances")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                    FlowLayout(spacing: 8) {
                        ForEach(Array(Self.suggestions.enumerated()), id: \.offset) { index, suggestion in
                            Button { onSuggestion(suggestion) } label: {
                                Text(suggestion)
                                    .foregroundStyle(Color.primary)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(minHeight: 44)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(dynamicTypeSize.isAccessibilitySize ? .roundedRectangle(radius: 16) : .capsule)
                            .opacity(hasAppeared ? 1 : 0)
                            .scaleEffect(hasAppeared ? 1 : 0.8)
                            .offset(y: hasAppeared ? 0 : 12)
                            .animation(reduceMotion ? nil : .spring(duration: 0.4).delay(Double(index) * 0.06), value: hasAppeared)
                        }
                    }
                    .padding(.top, 24)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollEdgeEffectStyle(.hard, for: .bottom)
        }
        .onAppear { hasAppeared = true }
    }
}
