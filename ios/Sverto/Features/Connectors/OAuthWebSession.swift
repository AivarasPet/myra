import AuthenticationServices
import UIKit

final class OAuthWebSession {
    private var session: ASWebAuthenticationSession?
    private var contextProvider: FixedPresentationContext?

    func authenticate(url: URL) async throws -> URL? {
        guard let anchor = Self.foregroundWindow() else {
            throw OAuthWebSessionError.noPresentationWindow
        }
        let contextProvider = FixedPresentationContext(anchor: anchor)
        self.contextProvider = contextProvider
        defer {
            session = nil
            self.contextProvider = nil
        }
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callback: .customScheme(DeepLink.scheme)) { @Sendable callbackURL, error in
                if let error {
                    if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin {
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                continuation.resume(returning: callbackURL)
            }
            session.presentationContextProvider = contextProvider
            self.session = session
            if !session.start() {
                self.session = nil
                continuation.resume(throwing: OAuthWebSessionError.failedToStart)
            }
        }
    }

    func cancel() {
        session?.cancel()
        session = nil
        contextProvider = nil
    }

    private static func foregroundWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        return scene?.keyWindow ?? scene?.windows.first
    }
}

private final class FixedPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let anchor: ASPresentationAnchor

    init(anchor: ASPresentationAnchor) {
        self.anchor = anchor
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        anchor
    }
}
