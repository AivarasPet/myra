import Foundation
import SvertoCore

// Every money string comes from the Rust core so iOS and Android format identically.
enum Money {
    nonisolated static func format(_ amount: Double, ticker: String, signed: Bool = false) -> String {
        formatMoney(amount: amount, ticker: ticker, showSign: signed)
    }
}
