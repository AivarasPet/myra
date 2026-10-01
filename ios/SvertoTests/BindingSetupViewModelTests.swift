import Foundation
import SvertoCore
import Testing
@testable import Sverto

@MainActor
struct BindingSetupViewModelTests {
    @Test func failedLoadIsDistinctFromAnEmptyProviderResponse() async {
        let store = BindingSetupStore(noHandle: .init())
        store.setProviderResponse(.failure(.Parse(reason: "missing field accounts")))
        let model = BindingSetupViewModel(store: store, connectionId: "connection")

        await model.load()

        #expect(!model.loading)
        #expect(model.providerAccounts.isEmpty)
        #expect(model.loadError == "Couldn't load provider accounts. Pull down to try again.")
        #expect(model.error == nil)
    }

    @Test func successfulEmptyLoadHasNoFailure() async {
        let model = BindingSetupViewModel(store: BindingSetupStore(noHandle: .init()), connectionId: "connection")

        await model.load()

        #expect(!model.loading)
        #expect(model.providerAccounts.isEmpty)
        #expect(model.loadError == nil)
        #expect(model.error == nil)
    }

    @Test func successfulRetryClearsTheLoadFailureAndShowsAccounts() async {
        let store = BindingSetupStore(noHandle: .init())
        store.setProviderResponse(.failure(.Network(reason: "Offline")))
        let model = BindingSetupViewModel(store: store, connectionId: "connection")
        await model.load()
        let account = ProviderAccount(providerAccountId: "provider", displayName: "Savings", currency: "GBP", accountType: "Savings")
        store.setProviderResponse(.success([account]))

        await model.load()

        #expect(model.loadError == nil)
        #expect(model.providerAccounts == [account])
        #expect(!model.loading)
    }

    @Test func failedRefreshKeepsPreviouslyLoadedAccountsAlongsideTheError() async {
        let store = BindingSetupStore(noHandle: .init())
        let account = ProviderAccount(providerAccountId: "provider", displayName: "Savings", currency: "GBP", accountType: "Savings")
        store.setProviderResponse(.success([account]))
        let model = BindingSetupViewModel(store: store, connectionId: "connection")
        await model.load()
        store.setProviderResponse(.failure(.Network(reason: "Offline")))

        await model.load()

        #expect(model.providerAccounts == [account])
        #expect(model.loadError != nil)
        #expect(!model.loading)
    }

    @Test func failedBindingRemainsAnActionErrorWithoutChangingTheLoadState() async {
        let store = BindingSetupStore(noHandle: .init())
        let model = BindingSetupViewModel(store: store, connectionId: "connection")
        await model.load()

        await model.bind(providerAccountId: "provider", svertoAccountId: "sverto")

        #expect(model.error == "Couldn't link account")
        #expect(model.loadError == nil)
    }
}

nonisolated private final class BindingSetupStore: AppStore, @unchecked Sendable {
    private let lock = NSLock()
    private var providerResponse: Result<[ProviderAccount], ApiError> = .success([])

    func setProviderResponse(_ response: Result<[ProviderAccount], ApiError>) {
        lock.withLock { providerResponse = response }
    }

    override func listConnectorProviderAccounts(connectionId: String) async throws -> [ProviderAccount] {
        try lock.withLock { providerResponse }.get()
    }

    override func listConnectorBindings() async throws -> [ConnectorBinding] { [] }
    override func listSvertoAccounts() async throws -> [AccountListItem] { [] }

    override func createConnectorBinding(connectionId: String, svertoAccountId: String, providerAccountId: String?) async throws -> String {
        throw ApiError.Server(reason: "Couldn't link account", status: 400)
    }
}
