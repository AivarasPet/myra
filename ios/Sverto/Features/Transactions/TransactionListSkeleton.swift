import SwiftUI

struct TransactionListSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(width: 56, height: 12)
                ListSkeleton(rows: 7)
                SkeletonBlock(width: 84, height: 12)
                    .padding(.top, 12)
                ListSkeleton(rows: 4)
            }
            .padding(Layout.cardPadding)
        }
        .scrollDisabled(true)
        .background(.screenBackground)
        .accessibilityLabel("Loading transactions")
    }
}
