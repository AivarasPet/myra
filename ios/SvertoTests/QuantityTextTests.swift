import Foundation
import Testing
@testable import Sverto

struct QuantityTextTests {
    @Test func ordinaryHoldingsKeepGroupingAndTrimUnusedFractionDigits() {
        #expect(AssetFormat.units(14_650.4252) == "14,650.4252")
        #expect(AssetFormat.units(-70_449.165) == "-70,449.165")
        #expect(AssetFormat.units(39) == "39")
        #expect(AssetFormat.units(0) == "0")
        #expect(AssetFormat.units(-0.0) == "0")
    }

    @Test func fractionalHoldingsKeepMeaningfulDigitsBeyondFourPlaces() {
        #expect(AssetFormat.units(1.23456789) == "1.23456789")
        #expect(AssetFormat.units(0.0000123456789) == "0.0000123456789")
        #expect(AssetFormat.units(0.00000001) == "0.00000001")
        #expect(AssetFormat.units(-0.00000001) == "-0.00000001")
        #expect(AssetFormat.units(0.1 + 0.2) == "0.3")
    }

    @Test func extremeQuantitiesStayNonzeroWithoutLongRunsOfZeros() throws {
        for value in [1e-9, -1e-9, 1e-200, -1e-200, Double.leastNonzeroMagnitude, -Double.leastNonzeroMagnitude, 1e20] {
            let text = AssetFormat.units(value)
            let parsed = try #require(Double(text))
            #expect(parsed == value)
            #expect(text.contains("E"))
            #expect(text.count < 24)
        }
    }

    @Test func quantitiesRetainLocaleSpecificSeparators() {
        let german = Locale(identifier: "de_DE")
        #expect(QuantityText.format(1_234.56789, locale: german) == "1.234,56789")
        #expect(QuantityText.format(-0.00000001, locale: german) == "-0,00000001")
        #expect(ConnectorNames.quantity(0.000000001) == QuantityText.format(0.000000001, locale: .current))
    }
}
