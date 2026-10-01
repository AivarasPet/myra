import SvertoCore

struct AccountFormSnapshot: Equatable {
    let name: String
    let typeId: Int32?
    let liquidityId: Int32?
    let ownershipShare: Double
    let identifiers: Set<AccountIdentifier>
}
