import Foundation
import Testing
@testable import Sverto

private func route(_ text: String) throws -> DeepLinkAction? {
    DeepLink.route(for: try #require(URL(string: text)))
}

struct DeepLinkRouterTests {
    @Test func trueLayerCallbackOpensSettingsWithConnectorsThenConnectRoute() throws {
        let action = try route("sverto://connectors/truelayer?code=abc&state=xyz")

        #expect(action == .presentSettings([
            .connectors,
            .connectTrueLayer(code: "abc", state: "xyz", error: nil),
        ]))
    }

    @Test func enableBankingCallbackCarriesErrorWithoutCodeOrState() throws {
        let action = try route("sverto://connectors/enablebanking?error=access_denied")

        #expect(action == .presentSettings([
            .connectors,
            .connectEnableBanking(code: nil, state: nil, error: "access_denied"),
        ]))
    }

    @Test func enableBankingCallbackWithAllParameters() throws {
        let action = try route("sverto://connectors/enablebanking?code=c1&state=s1&error=e1")

        #expect(action == .presentSettings([
            .connectors,
            .connectEnableBanking(code: "c1", state: "s1", error: "e1"),
        ]))
    }

    @Test func quickUploadSelectsTransactionsTab() throws {
        #expect(try route("sverto://quick-upload") == .selectTab(.transactions))
        #expect(try route("sverto://quick-upload/") == .selectTab(.transactions))
    }

    @Test func schemeHostAndPathAreCaseInsensitive() throws {
        #expect(try route("SVERTO://Connectors/TrueLayer?code=A") == .presentSettings([
            .connectors,
            .connectTrueLayer(code: "A", state: nil, error: nil),
        ]))
        #expect(try route("Sverto://QUICK-UPLOAD") == .selectTab(.transactions))
    }

    @Test func trailingSlashOnConnectorPathIsAccepted() throws {
        #expect(try route("sverto://connectors/truelayer/") == .presentSettings([
            .connectors,
            .connectTrueLayer(code: nil, state: nil, error: nil),
        ]))
    }

    @Test func queryValuesArePercentDecodedAndEmptyValuesKept() throws {
        let action = try route("sverto://connectors/truelayer?code=&state=a%20b")

        #expect(action == .presentSettings([
            .connectors,
            .connectTrueLayer(code: "", state: "a b", error: nil),
        ]))
    }

    @Test func queryParameterNamesAreCaseSensitive() throws {
        let action = try route("sverto://connectors/truelayer?Code=abc")

        #expect(action == .presentSettings([
            .connectors,
            .connectTrueLayer(code: nil, state: nil, error: nil),
        ]))
    }

    @Test func rejectsForeignSchemes() throws {
        #expect(try route("https://connectors/truelayer?code=abc") == nil)
        #expect(try route("http://quick-upload") == nil)
        #expect(try route("svertox://quick-upload") == nil)
    }

    @Test func rejectsUnknownHostsAndPaths() throws {
        #expect(try route("sverto://connectors") == nil)
        #expect(try route("sverto://connectors/") == nil)
        #expect(try route("sverto://connectors/trading212") == nil)
        #expect(try route("sverto://connectors/truelayer/extra") == nil)
        #expect(try route("sverto://quick-upload/extra") == nil)
        #expect(try route("sverto://settings") == nil)
        #expect(try route("sverto://") == nil)
        #expect(try route("sverto:quick-upload") == nil)
    }
}
