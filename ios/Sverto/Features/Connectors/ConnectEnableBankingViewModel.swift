import Foundation
import Observation
import SvertoCore

@Observable
final class ConnectEnableBankingViewModel: OAuthConnectViewModel {
    static let countries = ["FI", "SE", "DK", "NO", "GB", "DE", "FR", "NL", "EE", "LV", "LT"]

    private(set) var country: String?
    private(set) var aspsps: [Aspsp] = []
    private(set) var selectedBank: String?
    private(set) var banksLoading = false

    init(store: AppStore) {
        super.init(store: store, kind: .enableBanking)
    }

    override var bankName: String? { selectedBank }

    override var bankCountry: String? {
        country.flatMap { $0.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0 }
    }

    func setCountry(_ country: String?) async {
        self.country = country
        aspsps = []
        selectedBank = nil
        await loadBanks()
    }

    func selectBank(_ name: String?) {
        selectedBank = name
    }

    private func loadBanks() async {
        guard let requested = bankCountry else { return }
        banksLoading = true
        do {
            let banks = try await store.listConnectorAspsps(providerKind: kind.rawValue, country: requested)
            guard country == requested else { return }
            aspsps = banks.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            banksLoading = false
        } catch {
            guard country == requested else { return }
            fail(error.friendlyMessage)
            banksLoading = false
        }
    }
}
