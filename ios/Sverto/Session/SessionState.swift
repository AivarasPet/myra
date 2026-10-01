import Foundation
import SvertoCore

enum ServerConnectionStatus: Equatable {
    case idle
    case checking(url: String)
    case found(url: String, info: ServerInfo)
    case error(url: String, message: String)
}

enum SessionState: Equatable {
    case loading
    case welcome
    case serverUrl(lastUrl: String, status: ServerConnectionStatus)
    case connecting
    case connectError(message: String)
    case signIn(isSubmitting: Bool, errorMessage: String?)
    case signUp
    case clerkLogin
    case signedIn(generation: Int)
}

enum ServerCopy {
    static let hostedUnreachable = "Couldn't reach the hosted service at %@. Make sure it's running, then retry."
    static let serverNotFound = "We couldn't find a Sverto server at this address. Check the URL and try again."
    static let badCredentials = "That username or password isn't correct."
    static let signInServerFailure = "The server couldn't sign you in. Please try again."
    static let signInNetwork = "We couldn't reach this server. Check your connection and try again."
    static let signInTimeout = "The server took too long to respond. Please try again."
    static let signInParse = "The server returned an unexpected response."
    static let signInMissingCredential = "Your saved session is no longer available. Please sign in again."
    static let signInUnknown = "Something went wrong while signing in. Please try again."
}
