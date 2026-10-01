import SwiftUI
import SvertoCore

struct BaseCurrencyPage: View {
    let model: OnboardingViewModel

    private var queryBinding: Binding<String> {
        Binding(get: { model.query }, set: { model.onQueryChange($0) })
    }

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your base currency")
                    .font(.title.weight(.semibold))
                Text("All balances and your net worth are reported in this currency. You can change it later in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                CurrencySearchField(text: queryBinding)
                    .padding(.top, 12)
            }
            .fixedSize(horizontal: false, vertical: true)
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            if let error = model.currencyLoadError {
                VStack(alignment: .leading, spacing: 12) {
                    FormErrorRow(message: error)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        Task { await model.loadCurrencies() }
                    } label: {
                        Text("Retry")
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.isLoadingCurrencies)
                    .accessibilityLabel("Retry loading currencies")
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            results
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .sensoryFeedback(.selection, trigger: model.selectedCurrency)
    }

    @ViewBuilder
    private var results: some View {
        if model.isLoadingCurrencies && model.currencyResults.isEmpty {
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, minHeight: 96)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else if model.currencyResults.isEmpty, model.currencyLoadError == nil {
            ContentUnavailableView(
                CurrencySearch.emptyMessage(for: model.query),
                systemImage: CurrencySearch.emptySymbol(for: model.query)
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        } else {
            ForEach(model.currencyResults, id: \.id) { asset in
                let isSelected = model.selectedCurrency?.id == asset.id
                Button {
                    model.selectCurrency(asset)
                } label: {
                    CurrencyRow(asset: asset, isSelected: isSelected)
                }
                .listRowBackground(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            }
        }
    }
}
