import Testing
@testable import Sverto

struct ChatScrollStateTests {
    @Test func incomingContentKeepsFollowingAtTheEnd() {
        var state = ChatScrollState()
        state.geometryChanged(isAtBottom: false)

        #expect(state.shouldFollowLatest)
    }

    @Test func fingerTrackingSuspendsFollowingBeforeMovement() {
        var state = ChatScrollState()
        state.phaseChanged(isUserScrolling: true, isAtBottom: true)

        #expect(!state.shouldFollowLatest)
    }

    @Test func deliberateScrollAwaySurvivesStreamingAndDeceleration() {
        var state = ChatScrollState()
        state.phaseChanged(isUserScrolling: true, isAtBottom: true)
        state.geometryChanged(isAtBottom: false)
        state.phaseChanged(isUserScrolling: true, isAtBottom: false)
        #expect(!state.shouldFollowLatest)

        state.phaseChanged(isUserScrolling: false, isAtBottom: false)
        state.geometryChanged(isAtBottom: false)
        #expect(!state.shouldFollowLatest)
    }

    @Test func returningToTheEndResumesAfterTheGestureFinishes() {
        var state = ChatScrollState()
        state.phaseChanged(isUserScrolling: true, isAtBottom: false)
        state.phaseChanged(isUserScrolling: false, isAtBottom: false)
        state.phaseChanged(isUserScrolling: true, isAtBottom: false)
        state.geometryChanged(isAtBottom: true)
        #expect(!state.shouldFollowLatest)

        state.phaseChanged(isUserScrolling: false, isAtBottom: true)
        #expect(state.shouldFollowLatest)
        state.geometryChanged(isAtBottom: false)
        #expect(state.shouldFollowLatest)
    }

    @Test func newUserTurnOrConversationResetsDeliberateScrollAway() {
        var state = ChatScrollState()
        state.phaseChanged(isUserScrolling: true, isAtBottom: false)
        state.phaseChanged(isUserScrolling: false, isAtBottom: false)
        state.reset()
        state.geometryChanged(isAtBottom: false)

        #expect(state.shouldFollowLatest)
    }

    @Test func explicitResetCanInterruptDeceleration() {
        var state = ChatScrollState()
        state.phaseChanged(isUserScrolling: true, isAtBottom: false)
        state.reset()
        state.phaseChanged(isUserScrolling: false, isAtBottom: false)

        #expect(state.shouldFollowLatest)
    }

    @Test func programmaticScrollCompletionKeepsFollowing() {
        var state = ChatScrollState()
        state.phaseChanged(isUserScrolling: false, isAtBottom: false)

        #expect(state.shouldFollowLatest)
    }
}
