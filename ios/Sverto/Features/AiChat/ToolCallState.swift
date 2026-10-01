enum ToolCallState: String {
    case inputAvailable = "input-available"
    case outputAvailable = "output-available"
    case approvalRequested = "approval-requested"
    case outputDenied = "output-denied"
    case outputError = "output-error"
}
