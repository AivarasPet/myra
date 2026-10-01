import SvertoCore
import Testing
@testable import Sverto

struct AccountIdentifierKindTests {
    @Test func rawValuesMatchServerKeys() {
        #expect(AccountIdentifierKind.cardLast4.rawValue == "card_last4")
        #expect(AccountIdentifierKind.accountNumber.rawValue == "account_number")
        #expect(AccountIdentifierKind.iban.rawValue == "iban")
        #expect(AccountIdentifierKind.allCases.count == 3)
        for kind in AccountIdentifierKind.allCases {
            #expect(kind.id == kind.rawValue)
        }
    }

    @Test func labelsAndFieldLabels() {
        #expect(AccountIdentifierKind.cardLast4.label == "Card ending")
        #expect(AccountIdentifierKind.accountNumber.label == "Account number")
        #expect(AccountIdentifierKind.iban.label == "IBAN")
        #expect(AccountIdentifierKind.iban.valueFieldLabel == "IBAN")
        #expect(AccountIdentifierKind.cardLast4.valueFieldLabel == "Last 4 digits")
        #expect(AccountIdentifierKind.accountNumber.valueFieldLabel == "Account number")
    }

    @Test func onlyIbanUsesTheFullKeyboard() {
        #expect(AccountIdentifierKind.cardLast4.usesNumericKeyboard)
        #expect(AccountIdentifierKind.accountNumber.usesNumericKeyboard)
        #expect(!AccountIdentifierKind.iban.usesNumericKeyboard)
    }

    @Test func labelForKeyFallsBackToTheRawKey() {
        #expect(AccountIdentifierKind.label(forKey: "card_last4") == "Card ending")
        #expect(AccountIdentifierKind.label(forKey: "iban") == "IBAN")
        #expect(AccountIdentifierKind.label(forKey: "sort_code") == "sort_code")
    }

    @Test func cardLast4NormalisationKeepsOnlyTheFirstFourAsciiDigits() {
        #expect(AccountIdentifierKind.cardLast4.normalize("1234") == "1234")
        #expect(AccountIdentifierKind.cardLast4.normalize("**** 1234") == "1234")
        #expect(AccountIdentifierKind.cardLast4.normalize("123456") == "1234")
        #expect(AccountIdentifierKind.cardLast4.normalize("1a2b3c4d5e") == "1234")
        #expect(AccountIdentifierKind.cardLast4.normalize("١٢٣٤") == "")
        #expect(AccountIdentifierKind.cardLast4.normalize("") == "")
    }

    @Test func accountNumberNormalisationStripsEverythingButAsciiDigits() {
        #expect(AccountIdentifierKind.accountNumber.normalize("12-34 56 78") == "12345678")
        #expect(AccountIdentifierKind.accountNumber.normalize("acct: 0099") == "0099")
        #expect(AccountIdentifierKind.accountNumber.normalize("1234567890123456789012345678901234567890").count == 40)
        #expect(AccountIdentifierKind.accountNumber.normalize("١٢٣") == "")
    }

    @Test func ibanNormalisationRemovesWhitespaceAndUppercases() {
        #expect(AccountIdentifierKind.iban.normalize("gb82 west 1234 5698 7654 32") == "GB82WEST12345698765432")
        #expect(AccountIdentifierKind.iban.normalize(" DE89\t3704\n0044 0532 0130 00 ") == "DE89370400440532013000")
        #expect(AccountIdentifierKind.iban.normalize("gb-82") == "GB-82")
    }

    @Test func cardLast4RequiresExactlyFourDigits() {
        #expect(AccountIdentifierKind.cardLast4.validationError(for: "1234") == nil)
        #expect(AccountIdentifierKind.cardLast4.validationError(for: "0000") == nil)
        #expect(AccountIdentifierKind.cardLast4.validationError(for: "123") == "Card ending must be 4 digits.")
        #expect(AccountIdentifierKind.cardLast4.validationError(for: "12345") == "Card ending must be 4 digits.")
        #expect(AccountIdentifierKind.cardLast4.validationError(for: "12a4") == "Card ending must be 4 digits.")
        #expect(AccountIdentifierKind.cardLast4.validationError(for: "") == "Card ending must be 4 digits.")
    }

    @Test func accountNumberRequiresFourToThirtyFourDigits() {
        #expect(AccountIdentifierKind.accountNumber.validationError(for: "1234") == nil)
        #expect(AccountIdentifierKind.accountNumber.validationError(for: String(repeating: "9", count: 34)) == nil)
        #expect(AccountIdentifierKind.accountNumber.validationError(for: "123") == "Account number must be 4–34 digits.")
        #expect(AccountIdentifierKind.accountNumber.validationError(for: String(repeating: "9", count: 35)) == "Account number must be 4–34 digits.")
        #expect(AccountIdentifierKind.accountNumber.validationError(for: "12 34") == "Account number must be 4–34 digits.")
        #expect(AccountIdentifierKind.accountNumber.validationError(for: "") == "Account number must be 4–34 digits.")
    }

    @Test func ibanRequiresCountryCheckDigitsAndBban() {
        #expect(AccountIdentifierKind.iban.validationError(for: "GB82WEST12345698765432") == nil)
        #expect(AccountIdentifierKind.iban.validationError(for: "DE89370400440532013000") == nil)
        #expect(AccountIdentifierKind.iban.validationError(for: "LT121000011101001000") == nil)
        #expect(AccountIdentifierKind.iban.validationError(for: "AA00" + String(repeating: "Z", count: 11)) == nil)
        #expect(AccountIdentifierKind.iban.validationError(for: "AA00" + String(repeating: "Z", count: 30)) == nil)
        #expect(AccountIdentifierKind.iban.validationError(for: "AA00" + String(repeating: "Z", count: 10)) == "Enter a valid IBAN.")
        #expect(AccountIdentifierKind.iban.validationError(for: "AA00" + String(repeating: "Z", count: 31)) == "Enter a valid IBAN.")
        #expect(AccountIdentifierKind.iban.validationError(for: "gb82west12345698765432") == "Enter a valid IBAN.")
        #expect(AccountIdentifierKind.iban.validationError(for: "GB82 WEST 1234 5698 7654 32") == "Enter a valid IBAN.")
        #expect(AccountIdentifierKind.iban.validationError(for: "G882WEST12345698765432") == "Enter a valid IBAN.")
        #expect(AccountIdentifierKind.iban.validationError(for: "GBX2WEST12345698765432") == "Enter a valid IBAN.")
        #expect(AccountIdentifierKind.iban.validationError(for: "") == "Enter a valid IBAN.")
    }

    @Test func normalisedUserInputPassesValidation() {
        let card = AccountIdentifierKind.cardLast4
        let number = AccountIdentifierKind.accountNumber
        let iban = AccountIdentifierKind.iban

        #expect(card.validationError(for: card.normalize("**** **** **** 4321")) == nil)
        #expect(number.validationError(for: number.normalize("12-34-56-78")) == nil)
        #expect(iban.validationError(for: iban.normalize("gb82 west 1234 5698 7654 32")) == nil)
    }

    @Test func ibanDisplayValueIsMaskedWhenLongerThanTwelve() {
        #expect(AccountIdentifierKind.displayValue(AccountIdentifier(kind: "iban", value: "GB82WEST12345698765432")) == "GB82…5432")
        #expect(AccountIdentifierKind.displayValue(AccountIdentifier(kind: "iban", value: "GB82WEST12345")) == "GB82…2345")
    }

    @Test func shortIbansAndOtherKindsDisplayVerbatim() {
        #expect(AccountIdentifierKind.displayValue(AccountIdentifier(kind: "iban", value: "GB82WEST1234")) == "GB82WEST1234")
        #expect(AccountIdentifierKind.displayValue(AccountIdentifier(kind: "card_last4", value: "4321")) == "4321")
        #expect(AccountIdentifierKind.displayValue(AccountIdentifier(kind: "account_number", value: "12345678901234567890")) == "12345678901234567890")
        #expect(AccountIdentifierKind.displayValue(AccountIdentifier(kind: "custom", value: "ABCDEFGHIJKLMNOP")) == "ABCDEFGHIJKLMNOP")
    }
}
