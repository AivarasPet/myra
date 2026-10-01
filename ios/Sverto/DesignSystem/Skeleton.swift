import SwiftUI

struct SkeletonBlock: View {
    private let width: CGFloat?
    private let height: CGFloat

    init(width: CGFloat? = nil, height: CGFloat) {
        self.width = width
        self.height = height
    }

    var body: some View {
        RoundedRectangle(cornerRadius: min(6, height / 2))
            .fill(Color(.tertiarySystemFill))
            .frame(width: width, height: height)
            .shimmering()
            .accessibilityHidden(true)
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let bandWidth = geometry.size.width * 0.6
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.35), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: bandWidth)
                    .offset(x: -bandWidth + (geometry.size.width + bandWidth) * phase)
                }
                .mask(content)
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

struct ListSkeleton: View {
    private let rows: Int

    init(rows: Int = 5) {
        self.rows = rows
    }

    var body: some View {
        GroupedCard {
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { index in
                    HStack(spacing: Layout.rowSpacing) {
                        SkeletonBlock(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            SkeletonBlock(width: 140, height: 16)
                            SkeletonBlock(width: 72, height: 12)
                        }
                        Spacer(minLength: 8)
                        VStack(alignment: .trailing, spacing: 6) {
                            SkeletonBlock(width: 64, height: 16)
                            SkeletonBlock(width: 48, height: 12)
                        }
                    }
                    .padding(.horizontal, Layout.cardPadding)
                    .padding(.vertical, Layout.rowSpacing)
                    if index < rows - 1 {
                        RowDivider()
                    }
                }
            }
        }
        .accessibilityLabel("Loading")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SkeletonBlock(width: 180, height: 32)
        SkeletonBlock(height: 180)
        ListSkeleton(rows: 3)
    }
    .padding()
    .background(.screenBackground)
}
