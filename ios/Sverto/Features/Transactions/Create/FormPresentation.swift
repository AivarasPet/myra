import Foundation
import Observation

enum AccountPickerTarget: String, Identifiable {
    case primary
    case secondary
    var id: String { rawValue }
}

enum AssetSearchTarget: String, Identifiable {
    case primary
    case secondary
    case origin
    var id: String { rawValue }
}

enum FormField: Hashable {
    case primaryAmount
    case secondaryAmount
    case description
    case correction
}

@Observable
final class FormPresentation {
    var accountTarget: AccountPickerTarget?
    var assetTarget: AssetSearchTarget?
    var isCategorySearchPresented = false
    var isTypePickerPresented = false
}
