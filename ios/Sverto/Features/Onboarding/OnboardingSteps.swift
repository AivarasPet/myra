import Foundation

enum OnboardingStepId: CaseIterable, Hashable {
    case welcome
    case baseCurrency
    case notifications

    var introducedIn: Int32 {
        switch self {
        case .welcome, .baseCurrency, .notifications: 1
        }
    }
}

enum OnboardingSteps {
    static let currentVersion: Int32 = 1

    static func steps(forCompletedVersion version: Int32) -> [OnboardingStepId] {
        OnboardingStepId.allCases.filter { $0.introducedIn > version }
    }
}
