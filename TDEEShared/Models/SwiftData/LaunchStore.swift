import Observation
import Foundation

/// Coordinates a single launch-time store open and offers recovery.
///
/// The on-disk SwiftData store can fail to open — a corrupt or incompatible file, or no storage at
/// all. Rather than trap the process, the app shows a recovery screen. `LaunchStore` owns the
/// outcome and the two recovery actions:
/// - `retry()` re-opens the existing on-disk store — the fix for a transient failure.
/// - `reset()` wipes the store and opens a fresh one — the fix for a corrupt/incompatible store, and
///   the only path that recovers data the open can't read.
///
/// Used by both the phone (`TDEEApp`) and the watch (`TDEEWatchApp`) apps: each builds its own
/// models from the repository handed out by `outcome == .ready`.
@Observable
@MainActor
final class LaunchStore {

    /// The outcome of the last attempt. `.ready` carries the repository the app builds from;
    /// `.failed` carries a friendly, user-facing description.
    enum Outcome {
        case ready(ProfileRepository)
        case failed(LaunchFailure)
    }

    var outcome: Outcome = .failed(.notAttempted)

    /// The opener, injected for tests. Defaults to opening the real on-disk store.
    private var opener: (Bool) throws -> SwiftDataContainer

    /// Open the store and attempt the first launch. The opener runs synchronously —
    /// `ModelContainer` initialisation is blocking — so `outcome` is set before the first body
    /// renders, and the app never starts on a half-opened store.
    convenience init() {
        self.init(opener: { reset in try SwiftDataContainer.makeStore(reset: reset) })
        launch()
    }

    /// Injectable opener for tests: pass a fake that throws to exercise the recovery screen.
    init(opener: @escaping (Bool) throws -> SwiftDataContainer) {
        self.opener = opener
    }

    /// Attempt the first open (no wipe).
    func launch() {
        attempt(reset: false)
    }

    /// Re-open the existing on-disk store. The recovery for a transient open failure.
    func retry() {
        attempt(reset: false)
    }

    /// Wipe the on-disk store and open a fresh one. The recovery for a corrupt/incompatible store.
    func reset() {
        attempt(reset: true)
    }

    private func attempt(reset: Bool) {
        do {
            outcome = .ready(try opener(reset).profileRepository)
        } catch {
            outcome = .failed(LaunchFailure(underlying: error, afterReset: reset))
        }
    }
}

/// A friendly, user-facing description of a store-open failure, plus the underlying error.
///
/// The view shows `userMessage` as the headline and `detail` as the explanation (including the
/// "potential resolution": try again, or reset). `underlying` is kept for logging/telemetry.
struct LaunchFailure: Error {
    var userMessage: String
    var detail: String
    var underlying: Error

    /// The placeholder shown before any attempt — the store's initial `outcome`.
    static let notAttempted = LaunchFailure(
        userMessage: "TDEE couldn't open its saved data.",
        detail: "Starting the app.",
        underlying: SwiftDataError.failedToSave)

    /// The explicit-field init. Declaring `init(underlying:afterReset:)` below suppresses the
    /// synthesized memberwise init, so this one restores it for callers (such as `notAttempted`)
    /// that supply their own `userMessage`/`detail` rather than the templated recovery text.
    init(userMessage: String, detail: String, underlying: Error) {
        self.userMessage = userMessage
        self.detail = detail
        self.underlying = underlying
    }

    init(underlying: Error, afterReset: Bool) {
        self.underlying = underlying
        userMessage = afterReset
            ? "TDEE still couldn't open its saved data, even after a reset."
            : "TDEE couldn't open its saved data."
        detail = "This can happen if the saved data is damaged or an update changed its format. "
            + "Try again, or reset the saved data to start fresh."
            + (afterReset ? " A repeated failure after a reset may mean storage is full or unwritable." : "")
    }
}
