import SvertoCore
import SwiftUI

struct ConnectorDetailScreen: View {
    let providerKind: String
    @Environment(AppServices.self) private var services

    var body: some View {
        if let kind = ConnectorKind(rawValue: providerKind) {
            ConnectorDetailContent(store: services.store, kind: kind)
        } else {
            EmptyState(title: "Unknown connector", systemImage: ConnectorCatalog.fallbackSystemImage)
        }
    }
}

private struct ConnectorDetailContent: View {
    @State private var model: ConnectorsViewModel
    @Environment(ShellState.self) private var shell
    private let kind: ConnectorKind

    init(store: AppStore, kind: ConnectorKind) {
        _model = State(initialValue: ConnectorsViewModel(store: store))
        self.kind = kind
    }

    private var connector: ConnectorInfo { kind.info }

    private var connections: [ConnectorConnection] { model.connections(for: kind) }

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    ProviderAvatar(systemImage: connector.systemImage, size: 64)
                    Text(connector.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            if !connections.isEmpty {
                Section("Active connections") {
                    ForEach(connections, id: \.id) { connection in
                        ConnectionRow(connection: connection) {
                            shell.push(.connectionDetail(connectionId: connection.id))
                        }
                    }
                }
            } else if model.loading {
                Section { ConnectionCardSkeleton() }
            } else {
                Section {
                    EmptyState(
                        title: "Nothing connected yet",
                        systemImage: connector.systemImage,
                        description: "Connect to import your accounts and keep them in sync automatically."
                    )
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(connector.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            ConnectorHeroButton(title: "Connect", systemImage: ConnectorCatalog.fallbackSystemImage) {
                shell.push(kind.connectRoute)
            }
        }
        .task { await model.load() }
        .refreshable { await model.load() }
        .toastOnError(model.error)
    }
}

private struct ConnectionRow: View {
    let connection: ConnectorConnection
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(connection.kindLabel)
                    statusLayout {
                        ConnectionStatusChip(status: connection.connectionStatus)
                        if let consent = connection.consentLabel {
                            Text(consent)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(.primary)
    }

    private var statusLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))
    }
}
