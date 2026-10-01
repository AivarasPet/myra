import SvertoCore
import SwiftUI

struct ConnectEnableBankingScreen: View {
    let oauthCode: String?
    let oauthState: String?
    let oauthError: String?
    @Environment(AppServices.self) private var services

    var body: some View {
        ConnectEnableBankingContent(store: services.store, oauthCode: oauthCode, oauthState: oauthState, oauthError: oauthError)
    }
}

private struct ConnectEnableBankingContent: View {
    @State private var model: ConnectEnableBankingViewModel
    @State private var webSession = OAuthWebSession()
    @State private var isPickingCountry = false
    @State private var isPickingBank = false
    private let oauthCode: String?
    private let oauthState: String?
    private let oauthError: String?

    init(store: AppStore, oauthCode: String?, oauthState: String?, oauthError: String?) {
        _model = State(initialValue: ConnectEnableBankingViewModel(store: store))
        self.oauthCode = oauthCode
        self.oauthState = oauthState
        self.oauthError = oauthError
    }

    private static let steps = ConnectExplainer.openBankingSteps(
        first: ConnectStep(systemImage: "magnifyingglass", text: "Pick your country and find your bank")
    )

    private var bankPlaceholder: String {
        model.banksLoading ? "Loading…" : "Load banks first"
    }

    var body: some View {
        Group {
            if model.phase == .working {
                ConnectWorkingView()
            } else {
                Form {
                    Section {
                        ConnectExplainer(
                            systemImage: ConnectorCatalog.bankSystemImage,
                            intro: ConnectExplainer.openBankingIntro,
                            steps: Self.steps
                        )
                        .listRowBackground(Color.clear)
                    }
                    Section {
                        ConnectorPickerRow(
                            title: "Country",
                            value: model.country.map(CountryNames.display),
                            placeholder: "Pick a country",
                            systemImage: "magnifyingglass",
                            isLoading: false
                        ) {
                            isPickingCountry = true
                        }
                        ConnectorPickerRow(
                            title: "Your bank",
                            value: model.selectedBank,
                            placeholder: bankPlaceholder,
                            systemImage: "chevron.forward",
                            isLoading: model.banksLoading
                        ) {
                            isPickingBank = true
                        }
                        .disabled(model.aspsps.isEmpty)
                    }
                    if let message = model.phaseMessage {
                        Section {
                            FormErrorRow(message: message)
                        }
                    }
                }
            }
        }
        .navigationTitle("Connect your bank")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if model.phase != .working {
                ConnectorHeroButton(title: "Continue to your bank", systemImage: ConnectorCatalog.bankSystemImage) {
                    Task { await model.begin() }
                }
                .disabled(model.selectedBank == nil)
            }
        }
        .sheet(isPresented: $isPickingCountry) {
            CountryPickerSheet(countries: ConnectEnableBankingViewModel.countries, selected: model.country) { code in
                Task { await model.setCountry(code) }
            }
        }
        .sheet(isPresented: $isPickingBank) {
            BankPickerSheet(banks: model.aspsps, selected: model.selectedBank) { bank in
                model.selectBank(bank.name)
            }
        }
        .oauthConnectEffects(model: model, webSession: webSession, oauthState: oauthState, oauthCode: oauthCode, oauthError: oauthError)
    }
}

private struct ConnectorPickerRow: View {
    let title: String
    let value: String?
    let placeholder: String
    let systemImage: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            LabeledContent(title) {
                HStack(spacing: 8) {
                    Text(value ?? placeholder)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: systemImage)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .accessibilityValue(value ?? placeholder)
    }
}
