import SvertoCore
import SwiftUI

struct ConnectorsScreen: View {
    @Environment(AppServices.self) private var services

    var body: some View {
        ConnectorsList(store: services.store)
    }
}

private struct ConnectorsList: View {
    @State private var model: ConnectorsViewModel
    @Environment(ShellState.self) private var shell

    init(store: AppStore) {
        _model = State(initialValue: ConnectorsViewModel(store: store))
    }

    var body: some View {
        List {
            Section {
                ForEach(ConnectorCatalog.all) { connector in
                    ConnectorRow(connector: connector, activeCount: model.activeCount(for: connector.kind)) {
                        shell.push(.connectorDetail(providerKind: connector.kind.rawValue))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Connected Services")
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.load() }
        .refreshable { await model.load() }
        .toastOnError(model.error)
    }
}

private struct ConnectorRow: View {
    let connector: ConnectorInfo
    let activeCount: Int
    let action: () -> Void

    private var subtitle: String {
        activeCount > 0 ? "\(connector.tagline) · \(activeCount) connected" : connector.tagline
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ProviderAvatar(systemImage: connector.systemImage, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(connector.name)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(.primary)
        .accessibilityLabel("\(connector.name), \(subtitle)")
    }
}
