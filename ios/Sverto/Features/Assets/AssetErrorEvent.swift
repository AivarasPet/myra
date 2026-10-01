import Foundation

struct AssetErrorEvent: Equatable {
    let id = UUID()
    let message: String

    init(_ error: Error) {
        message = error.friendlyMessage
    }

    init(message: String) {
        self.message = message
    }
}
