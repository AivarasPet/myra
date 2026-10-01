import Testing
@testable import Sverto

private let allDefinitions = TransactionTypeCatalog.groups.flatMap(\.types)

private let expectedKeys: Set<String> = [
    "regular_transaction", "account_fees",
    "asset_purchase", "asset_sale", "asset_trade", "cash_dividend", "asset_dividend", "asset_balance_transfer",
    "cash_transfer_in", "cash_transfer_out", "cash_balance_transfer", "asset_transfer_in", "asset_transfer_out",
]

struct TransactionTypeCatalogTests {
    @Test func hasThirteenUniqueKeys() {
        #expect(allDefinitions.count == 13)
        #expect(Set(allDefinitions.map(\.key)) == expectedKeys)
    }

    @Test func hasThreeGroupsInEverydayInvestmentsTransfersOrder() {
        #expect(TransactionTypeCatalog.groups.map(\.title) == ["Everyday", "Investments", "Transfers"])
        #expect(TransactionTypeCatalog.groups.map { $0.types.count } == [2, 6, 5])
        #expect(TransactionTypeCatalog.groups.first?.types.first == TransactionTypeCatalog.regular)
    }

    @Test func groupIdsAreTheirTitles() {
        for group in TransactionTypeCatalog.groups {
            #expect(group.id == group.title)
        }
    }

    @Test func everyDefinitionIsFullyLabelled() {
        for definition in allDefinitions {
            #expect(!definition.key.isEmpty)
            #expect(!definition.label.isEmpty)
            #expect(!definition.description.isEmpty)
            #expect(!definition.systemImage.isEmpty)
            #expect(definition.id == definition.key)
        }
    }

    @Test func labelsAreUniqueAcrossTypes() {
        #expect(Set(allDefinitions.map(\.label)).count == allDefinitions.count)
    }

    @Test func definitionLookupFindsEveryKey() {
        for definition in allDefinitions {
            #expect(TransactionTypeCatalog.definition(for: definition.key) == definition)
        }
    }

    @Test func definitionLookupRejectsUnknownAndApiKeys() {
        #expect(TransactionTypeCatalog.definition(for: "bogus") == nil)
        #expect(TransactionTypeCatalog.definition(for: "regular") == nil)
        #expect(TransactionTypeCatalog.definition(for: "") == nil)
    }

    @Test func catalogLabelsAgreeWithFormConfigLabels() {
        for definition in allDefinitions {
            #expect(TransactionTypeCatalog.label(for: definition.key) == TransactionTypeConfig.forKey(definition.key).label)
        }
    }

    @Test func labelForUnknownKeyFallsBackToPurchase() {
        #expect(TransactionTypeCatalog.label(for: "bogus") == "Purchase")
        #expect(TransactionTypeCatalog.label(for: "regular") == "Purchase")
    }

    @Test func everyKeyHasADedicatedFormConfig() {
        for key in expectedKeys where key != "regular_transaction" {
            #expect(TransactionTypeConfig.forKey(key) != TransactionTypeConfig.regularTransaction)
        }
        #expect(TransactionTypeConfig.forKey("regular_transaction") == TransactionTypeConfig.regularTransaction)
    }
}

struct ApiTypeToConfigKeyTests {
    @Test func regularMapsToRegularTransaction() {
        #expect(apiTypeToConfigKey("regular") == "regular_transaction")
        #expect(TransactionTypeConfig.regularApiType == "regular")
        #expect(TransactionTypeConfig.regularTransaction.apiType == "regular")
        #expect(TransactionTypeConfig.regularTransaction.key == TransactionTypeCatalog.regular.key)
    }

    @Test func everyOtherKeyIsPassedThrough() {
        for key in expectedKeys where key != "regular_transaction" {
            #expect(apiTypeToConfigKey(key) == key)
        }
        #expect(apiTypeToConfigKey("unknown_type") == "unknown_type")
        #expect(apiTypeToConfigKey("") == "")
    }

    @Test func roundTripsThroughFormConfigApiTypeForEveryKey() {
        for key in expectedKeys {
            #expect(apiTypeToConfigKey(TransactionTypeConfig.forKey(key).apiType) == key)
        }
    }

    @Test func apiTypesAreUniqueAcrossKeys() {
        #expect(Set(expectedKeys.map { TransactionTypeConfig.forKey($0).apiType }).count == expectedKeys.count)
    }
}
