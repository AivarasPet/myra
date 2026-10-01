import ClerkKit
import Foundation
import Observation

// The only place that touches Clerk.shared. When the build has no publishable key, Clerk is never
// configured and every accessor degrades to "no user" instead of trapping.
@Observable
final class ClerkGateway {
    let isConfigured: Bool

    init(isConfigured: Bool) {
        self.isConfigured = isConfigured
    }

    var isLoaded: Bool {
        isConfigured ? Clerk.shared.isLoaded : true
    }

    var userId: String? {
        isConfigured ? Clerk.shared.user?.id : nil
    }

    var displayName: String? {
        guard isConfigured, let user = Clerk.shared.user else { return nil }
        let name = [user.firstName, user.lastName].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? nil : name
    }

    var initials: String? {
        guard isConfigured, let user = Clerk.shared.user else { return nil }
        let parts = [user.firstName, user.lastName].compactMap { $0?.first }.map(String.init)
        return parts.isEmpty ? nil : parts.joined()
    }

    var email: String? {
        guard isConfigured else { return nil }
        return Clerk.shared.user?.primaryEmailAddress?.emailAddress
    }

    var imageURL: URL? {
        guard isConfigured, let raw = Clerk.shared.user?.imageUrl else { return nil }
        return URL(string: raw)
    }

    func waitUntilLoaded(timeout: Duration = .seconds(10)) async {
        guard isConfigured else { return }
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while !Clerk.shared.isLoaded, clock.now < deadline {
            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    func signOut() async {
        guard isConfigured else { return }
        try? await Clerk.shared.auth.signOut()
    }
}
