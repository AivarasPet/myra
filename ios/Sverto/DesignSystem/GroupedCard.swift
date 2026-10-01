import SwiftUI

struct GroupedCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.cardFill, in: .rect(cornerRadius: Layout.cardRadius))
    }
}

struct RowDivider: View {
    var leadingInset: CGFloat = Layout.cardPadding

    var body: some View {
        Divider()
            .padding(.leading, leadingInset)
    }
}

extension View {
    func groupedScreenBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(.screenBackground)
    }
}

#Preview {
    VStack(spacing: 16) {
        GroupedCard {
            VStack(spacing: 0) {
                Text("First row").padding(Layout.cardPadding)
                RowDivider()
                Text("Second row").padding(Layout.cardPadding)
            }
        }
    }
    .padding()
    .groupedScreenBackground()
}
