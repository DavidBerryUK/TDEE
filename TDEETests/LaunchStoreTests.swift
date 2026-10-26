import Testing
@testable import TDEE
import Foundation

// MARK: - LaunchStore Tests

/// PA-32: `LaunchStore` owns the launch-time store open and its two recoveries — `retry()`
/// re-opens the existing store (the fix for a transient failure) and `reset()` wipes it first
/// (the fix for a corrupt/incompatible store). The opener is injected so the recovery screen can
/// be driven without a real on-disk store; the production `convenience init()` is never touched
/// here, so no `default.store` file is read or written.
@Suite("LaunchStore Tests")
@MainActor
struct LaunchStoreTests {

    /// A controllable opener: records each `reset:` flag it was called with, and returns a
    /// pre-built in-memory container or throws a sentinel, per the currently configured `result`.
    /// A reference type so the tests can flip it between calls (transient failure → recovery).
    private final class Recorder {
        var resetFlags: [Bool] = []
        var result: Result<SwiftDataContainer, Error>

        init(result: Result<SwiftDataContainer, Error>) {
            self.result = result
        }

        func open(_ reset: Bool) throws -> SwiftDataContainer {
            resetFlags.append(reset)
            return try result.get()
        }
    }

    private struct OpenError: Error {}

    // MARK: - Laziness

    @Test("The opener is not called until launch / retry / reset")
    func openerIsLazy() {
        let recorder = Recorder(result: .success(SwiftDataContainer(isInMemory: true)))
        let store = LaunchStore(opener: { try recorder.open($0) })

        // The injecting init does not attempt an open; it starts at the placeholder failure.
        #expect(store.outcome.isFailed, "A freshly-injected store starts at .failed(.notAttempted)")
        #expect(recorder.resetFlags.isEmpty, "The opener must not run before an explicit attempt")
    }

    // MARK: - Happy path

    @Test("launch() opens without wiping and yields .ready")
    func launchYieldsReady() {
        let recorder = Recorder(result: .success(SwiftDataContainer(isInMemory: true)))
        let store = LaunchStore(opener: { try recorder.open($0) })

        store.launch()

        #expect(recorder.resetFlags == [false], "launch() must open without a wipe")
        #expect(store.outcome.isReady, "A successful open must yield .ready")
    }

    @Test("retry() re-opens without wiping (reset: false)")
    func retryPassesResetFalse() {
        let recorder = Recorder(result: .success(SwiftDataContainer(isInMemory: true)))
        let store = LaunchStore(opener: { try recorder.open($0) })

        store.retry()

        #expect(recorder.resetFlags == [false], "retry() must not wipe the store")
        #expect(store.outcome.isReady)
    }

    @Test("reset() wipes before opening (reset: true)")
    func resetPassesResetTrue() {
        let recorder = Recorder(result: .success(SwiftDataContainer(isInMemory: true)))
        let store = LaunchStore(opener: { try recorder.open($0) })

        store.reset()

        #expect(recorder.resetFlags == [true], "reset() must wipe the store before opening")
        #expect(store.outcome.isReady)
    }

    // MARK: - Failure & recovery

    @Test("A thrown open yields .failed")
    func failedOnThrow() {
        let recorder = Recorder(result: .failure(OpenError()))
        let store = LaunchStore(opener: { try recorder.open($0) })

        store.launch()

        #expect(recorder.resetFlags == [false])
        #expect(store.outcome.isFailed, "A thrown open must yield .failed")
        #expect(store.outcome.failure != nil, "The failure must carry a LaunchFailure")
    }

    @Test("retry() recovers a transient failure and lands .ready")
    func retryRecoversTransientFailure() {
        let recorder = Recorder(result: .failure(OpenError()))
        let store = LaunchStore(opener: { try recorder.open($0) })

        store.launch()
        #expect(store.outcome.isFailed, "The first open fails")

        // The transient condition clears; the opener now succeeds. retry() must open without wiping.
        recorder.result = .success(SwiftDataContainer(isInMemory: true))
        store.retry()

        #expect(recorder.resetFlags == [false, false], "Both launch and retry open without a wipe")
        #expect(store.outcome.isReady, "retry() must recover the failure")
    }

    @Test("The failure message reflects whether a reset was attempted")
    func failureMessageReflectsReset() {
        // The first attempt (no wipe) offers the resolution "try again, or reset".
        let beforeReset = LaunchStore(opener: { _ throws -> SwiftDataContainer in throw OpenError() })
        beforeReset.launch()
        #expect(beforeReset.outcome.failure?.userMessage == "TDEE couldn't open its saved data.")
        #expect(beforeReset.outcome.failure?.detail.contains("Try again, or reset the saved data to start fresh.") == true)

        // After a failed reset the message escalates and hints at full/unwritable storage.
        let afterReset = LaunchStore(opener: { _ throws -> SwiftDataContainer in throw OpenError() })
        afterReset.reset()
        #expect(afterReset.outcome.failure?.userMessage == "TDEE still couldn't open its saved data, even after a reset.")
        #expect(afterReset.outcome.failure?.detail.contains("storage is full or unwritable") == true)
    }
}

// MARK: - Outcome inspection

private extension LaunchStore.Outcome {
    var isReady: Bool {
        if case .ready = self { return true }
        return false
    }

    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }

    var failure: LaunchFailure? {
        if case .failed(let failure) = self { return failure }
        return nil
    }
}
