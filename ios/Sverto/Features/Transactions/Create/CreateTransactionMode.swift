import Foundation

enum CreateTransactionMode: Hashable {
    case new
    case edit(transactionId: String)
    case proposal(quickUploadId: String)
    case groupAdd
    case groupEdit(GroupTransactionItem)

    var isGroupMode: Bool {
        switch self {
        case .groupAdd, .groupEdit: true
        case .new, .edit, .proposal: false
        }
    }

    var saveTitle: String {
        switch self {
        case .new, .proposal: "Save transaction"
        case .edit: "Update transaction"
        case .groupAdd: "Add to Group"
        case .groupEdit: "Update"
        }
    }

    var loadsRemotely: Bool {
        switch self {
        case .edit, .proposal: true
        case .new, .groupAdd, .groupEdit: false
        }
    }
}
