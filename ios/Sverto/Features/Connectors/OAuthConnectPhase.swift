import Foundation

enum OAuthConnectPhase: Equatable {
    case idle
    case working
    case denied
    case completed
    case failed
}
