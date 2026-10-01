import SvertoCore
import SwiftUI

struct TransactionsModelsHost<Content: View>: View {
    @State private var transactions: TransactionsViewModel
    @State private var quickUploads: QuickUploadViewModel
    private let content: Content

    init(store: AppStore, @ViewBuilder content: () -> Content) {
        _transactions = State(initialValue: TransactionsViewModel(store: store))
        _quickUploads = State(initialValue: QuickUploadViewModel(store: store))
        self.content = content()
    }

    var body: some View {
        content
            .environment(transactions)
            .environment(quickUploads)
            .onAppear { quickUploads.start() }
            .onDisappear { quickUploads.stop() }
    }
}
