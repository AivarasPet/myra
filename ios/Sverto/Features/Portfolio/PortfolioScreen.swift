import SwiftUI
import SvertoCore

struct PortfolioScreen: View {
    @Environment(AppServices.self) private var services

    var body: some View {
        PortfolioRoot(store: services.store)
    }
}

private struct PortfolioRoot: View {
    @State private var portfolio: HomeViewModel
    @State private var markets: MarketsListViewModel
    @State private var query = ""
    @State private var isSearchPresented = false

    init(store: AppStore) {
        _portfolio = State(initialValue: HomeViewModel(store: store))
        _markets = State(initialValue: MarketsListViewModel(store: store))
    }

    var body: some View {
        PortfolioSearchSwitch(portfolio: portfolio, markets: markets)
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $query, isPresented: $isSearchPresented, placement: .toolbar, prompt: "Search assets")
            .searchToolbarBehavior(.minimize)
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarLeading) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundStyle(.tint)
                        .accessibilityLabel("Sverto")
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .onChange(of: query) { _, newValue in
                markets.onQueryChange(newValue)
            }
            .task { await portfolio.start() }
            .onDisappear { portfolio.stop() }
    }
}

private struct PortfolioSearchSwitch: View {
    let portfolio: HomeViewModel
    let markets: MarketsListViewModel

    @Environment(\.isSearching) private var isSearching
    @Environment(ShellState.self) private var shell

    var body: some View {
        Group {
            if isSearching {
                AssetSearchResults(model: markets) { asset in
                    shell.push(.assetOverview(assetId: asset.id, userAsset: false))
                }
            } else {
                PortfolioContent(model: portfolio) { holding in
                    shell.push(.assetOverview(assetId: holding.assetId, userAsset: false))
                }
            }
        }
        .onChange(of: isSearching, initial: true) { _, searching in
            if searching {
                markets.onSearchExpanded()
            }
        }
    }
}
