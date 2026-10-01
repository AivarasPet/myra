import Foundation
import SvertoCore

enum ConnectorKind: String, CaseIterable {
    case trueLayer = "truelayer"
    case trading212
    case enableBanking = "enablebanking"

    var isBank: Bool {
        switch self {
        case .trueLayer, .enableBanking: true
        case .trading212: false
        }
    }

    var connectRoute: AppRoute {
        switch self {
        case .trueLayer: .connectTrueLayer(code: nil, state: nil, error: nil)
        case .enableBanking: .connectEnableBanking(code: nil, state: nil, error: nil)
        case .trading212: .connectTrading212
        }
    }

    var info: ConnectorInfo {
        switch self {
        case .trueLayer:
            ConnectorInfo(
                kind: self,
                name: "TrueLayer",
                systemImage: ConnectorCatalog.bankSystemImage,
                tagline: "Bank accounts via Open Banking",
                description: "Connect your bank accounts through TrueLayer's Open Banking platform. Sverto imports balances and transaction history, and keeps them up to date. You authorise access at your bank; Sverto never sees your bank login."
            )
        case .trading212:
            ConnectorInfo(
                kind: self,
                name: "Trading 212",
                systemImage: ConnectorCatalog.brokerSystemImage,
                tagline: "Investment account history",
                description: "Import your Trading 212 orders, dividends and cash movements using a Trading 212 API key. You choose where the key is kept: on Sverto's servers, or only on this device."
            )
        case .enableBanking:
            ConnectorInfo(
                kind: self,
                name: "Enable Banking",
                systemImage: ConnectorCatalog.bankSystemImage,
                tagline: "European banks via Open Banking",
                description: "Connect your European bank accounts through the Enable Banking open banking platform. Sverto imports balances and transaction history, and keeps them up to date. You authorise access at your bank; Sverto never sees your bank login."
            )
        }
    }
}

struct ConnectorInfo: Identifiable, Hashable {
    let kind: ConnectorKind
    let name: String
    let systemImage: String
    let tagline: String
    let description: String

    var id: ConnectorKind { kind }
}

enum ConnectorCatalog {
    static let bankSystemImage = "building.columns"
    static let brokerSystemImage = "chart.xyaxis.line"
    static let fallbackSystemImage = "powerplug"

    static let all: [ConnectorInfo] = ConnectorKind.allCases.map(\.info)
}

extension ConnectorConnection {
    var kind: ConnectorKind? { ConnectorKind(rawValue: providerKind) }

    var kindLabel: String {
        if kind?.isBank == true {
            return "Bank connection"
        }
        switch credentialMode {
        case .stored: return "Stored key"
        case .transient: return "On-device key"
        case .clientSupplied: return "Client-driven"
        }
    }

    var consentLabel: String? {
        consentExpiresAt.map { "Consent until \(DateText.mediumDate(epochSeconds: $0))" }
    }

    var keyLabel: String? {
        providerKeyId.map { "Key · \($0.suffix(4))" }
    }
}
