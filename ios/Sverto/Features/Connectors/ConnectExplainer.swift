import SwiftUI

struct ConnectStep: Identifiable, Hashable {
    let systemImage: String
    let text: String

    var id: String { text }
}

struct ConnectExplainer: View {
    static let openBankingIntro = "Link your bank securely through Open Banking. Here's how it works:"

    static func openBankingSteps(first: ConnectStep) -> [ConnectStep] {
        [
            first,
            ConnectStep(systemImage: "checkmark.shield", text: "Approve access at your bank — Sverto never sees your login"),
            ConnectStep(systemImage: "arrow.triangle.2.circlepath", text: "Your transactions import automatically"),
        ]
    }

    let systemImage: String
    let intro: String
    let steps: [ConnectStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ProviderAvatar(systemImage: systemImage, size: 64)
                .frame(maxWidth: .infinity)
            Text(intro)
                .font(.body)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(steps) { step in
                    Label {
                        Text(step.text)
                            .font(.subheadline)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: step.systemImage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ConnectWorkingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Connecting your bank…")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.screenBackground)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    Form {
        Section {
            ConnectExplainer(
                systemImage: ConnectorCatalog.bankSystemImage,
                intro: ConnectExplainer.openBankingIntro,
                steps: ConnectExplainer.openBankingSteps(first: ConnectStep(systemImage: ConnectorCatalog.bankSystemImage, text: "Choose your bank"))
            )
        }
    }
}
