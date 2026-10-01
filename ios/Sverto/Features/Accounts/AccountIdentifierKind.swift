import Foundation
import SvertoCore

enum AccountIdentifierKind: String, CaseIterable, Identifiable {
    case cardLast4 = "card_last4"
    case accountNumber = "account_number"
    case iban

    var id: String { rawValue }

    var label: String {
        switch self {
        case .cardLast4: "Card ending"
        case .accountNumber: "Account number"
        case .iban: "IBAN"
        }
    }

    var valueFieldLabel: String {
        switch self {
        case .cardLast4: "Last 4 digits"
        case .accountNumber: "Account number"
        case .iban: "IBAN"
        }
    }

    var usesNumericKeyboard: Bool {
        self != .iban
    }

    func normalize(_ raw: String) -> String {
        switch self {
        case .cardLast4: String(raw.filter(Self.isAsciiDigit).prefix(4))
        case .accountNumber: raw.filter(Self.isAsciiDigit)
        case .iban: raw.filter { !$0.isWhitespace }.uppercased()
        }
    }

    func validationError(for value: String) -> String? {
        switch self {
        case .cardLast4:
            value.wholeMatch(of: /[0-9]{4}/) == nil ? "Card ending must be 4 digits." : nil
        case .accountNumber:
            value.wholeMatch(of: /[0-9]{4,34}/) == nil ? "Account number must be 4–34 digits." : nil
        case .iban:
            value.wholeMatch(of: /[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}/) == nil ? "Enter a valid IBAN." : nil
        }
    }

    static func label(forKey key: String) -> String {
        AccountIdentifierKind(rawValue: key)?.label ?? key
    }

    static func displayValue(_ identifier: AccountIdentifier) -> String {
        guard identifier.kind == AccountIdentifierKind.iban.rawValue, identifier.value.count > 12 else {
            return identifier.value
        }
        return "\(identifier.value.prefix(4))…\(identifier.value.suffix(4))"
    }

    private static func isAsciiDigit(_ character: Character) -> Bool {
        character.isASCII && character.isNumber
    }
}
