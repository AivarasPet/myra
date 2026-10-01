nonisolated struct ChatScrollState {
    private var followsLatest = true
    private var isUserScrolling = false

    var shouldFollowLatest: Bool { followsLatest && !isUserScrolling }

    mutating func geometryChanged(isAtBottom: Bool) {
        if isUserScrolling || isAtBottom {
            followsLatest = isAtBottom
        }
    }

    mutating func phaseChanged(isUserScrolling: Bool, isAtBottom: Bool) {
        if self.isUserScrolling, !isUserScrolling {
            followsLatest = isAtBottom
        }
        self.isUserScrolling = isUserScrolling
    }

    mutating func reset() {
        followsLatest = true
        isUserScrolling = false
    }
}
