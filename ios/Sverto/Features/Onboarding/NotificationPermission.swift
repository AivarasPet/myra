import UserNotifications

enum NotificationPermission {
    case granted
    case denied
    case notRequested

    static func current() async -> NotificationPermission {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: return .granted
        case .denied: return .denied
        case .notDetermined: return .notRequested
        @unknown default: return .notRequested
        }
    }

    static func request() async -> NotificationPermission {
        let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        return granted ? .granted : .denied
    }
}
