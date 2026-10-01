import SvertoCore
import SwiftUI

struct ConnectTrueLayerScreen: View {
    let oauthCode: String?
    let oauthState: String?
    let oauthError: String?
    @Environment(AppServices.self) private var services

    var body: some View {
        ConnectTrueLayerContent(store: services.store, oauthCode: oauthCode, oauthState: oauthState, oauthError: oauthError)
    }
}

private struct ConnectTrueLayerContent: View {
    @State private var model: OAuthConnectViewModel
    @State private var webSession = OAuthWebSession()
    private let oauthCode: String?
    private let oauthState: String?
    private let oauthError: String?

    init(store: AppStore, oauthCode: String?, oauthState: String?, oauthError: String?) {
        _model = State(initialValue: OAuthConnectViewModel(store: store, kind: .trueLayer))
        self.oauthCode = oauthCode
        self.oauthState = oauthState
        self.oauthError = oauthError
    }

    private static let steps = ConnectExplainer.openBankingSteps(
        first: ConnectStep(systemImage: ConnectorCatalog.bankSystemImage, text: "Choose your bank")
    )

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
            }
        }
        .oauthConnectEffects(model: model, webSession: webSession, oauthState: oauthState, oauthCode: oauthCode, oauthError: oauthError)
    }
}
