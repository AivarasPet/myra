import SwiftUI

struct PortfolioSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ChartSkeleton(plotOutset: Layout.cardPadding)
            SkeletonBlock(width: 80, height: 20)
            ListSkeleton(rows: 5)
        }
        .accessibilityLabel("Loading portfolio")
    }
}
