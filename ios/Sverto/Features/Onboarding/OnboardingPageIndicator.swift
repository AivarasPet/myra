import SwiftUI

struct OnboardingPageIndicator: View {
    let pageCount: Int
    let currentPage: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.accentColor : Color(.tertiaryLabel))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
            }
        }
        .animation(reduceMotion ? nil : .snappy, value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pageCount)")
    }
}
