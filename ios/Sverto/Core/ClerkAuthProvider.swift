import ClerkKit
import Foundation
import SvertoCore
import Synchronization

nonisolated final class ClerkAuthProvider: AuthProvider {
    private let isConfigured: Bool
    private let hasConnectivity: @Sendable () -> Bool
    private let cache = Mutex<String?>(nil)

    init(isConfigured: Bool, hasConnectivity: @escaping @Sendable () -> Bool) {
        self.isConfigured = isConfigured
        self.hasConnectivity = hasConnectivity
    }

    func getToken() async -> String? {
        guard isConfigured else { return nil }
        if !hasConnectivity() {
            return cache.withLock { $0 }
        }
        guard let jwt = await fetchClerkToken() else {
            invalidate()
            return nil
        }
        cache.withLock { $0 = jwt }
        return jwt
    }

    func getUserId() -> String? {
        guard isConfigured else { return nil }
        return MainActor.assumeIsolatedIfPossible { Clerk.shared.user?.id }
    }

    func invalidate() {
        cache.withLock { $0 = nil }
    }

    private func fetchClerkToken() async -> String? {
        do {
            return try await Clerk.shared.session?.getToken()
        } catch {
            return nil
        }
    }
}

extension MainActor {
    nonisolated static func assumeIsolatedIfPossible<T: Sendable>(_ body: @MainActor () -> T) -> T {
        if Thread.isMainThread {
            return MainActor.assumeIsolated(body)
        }
        return DispatchQueue.main.sync { MainActor.assumeIsolated(body) }
    }
}
