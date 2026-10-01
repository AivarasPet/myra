import SwiftUI

enum ToolCallPhase {
    case running
    case done
    case approval
    case denied
    case error

    init(state: ToolCallState) {
        switch state {
        case .inputAvailable: self = .running
        case .outputAvailable: self = .done
        case .approvalRequested: self = .approval
        case .outputDenied: self = .denied
        case .outputError: self = .error
        }
    }

    var statusLabel: String {
        switch self {
        case .running: "Running…"
        case .done: "Complete"
        case .approval: "Approval needed"
        case .denied: "Denied"
        case .error: "Error"
        }
    }

    var systemImage: String {
        switch self {
        case .running: "wrench.and.screwdriver"
        case .done: "checkmark"
        case .approval: "clock"
        case .denied: "xmark.circle"
        case .error: "exclamationmark.circle"
        }
    }

    var tileTint: Color {
        switch self {
        case .running, .denied: .secondary
        case .done: .accentColor
        case .approval: .orange
        case .error: .red
        }
    }

    var statusColor: Color {
        switch self {
        case .denied, .error: .red
        default: .secondary
        }
    }
}
