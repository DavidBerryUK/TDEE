# TDEE — Problem Analysis (v2)

**Scope:** Static analysis of the `TDEE` (iPhone), `TDEEWatch` (watchOS) and `TDEEShared` (shared calc/persistence/models) targets, with `TDEETests` read for coverage. This is a **continuation** of the 2026-10-22 report (`problem-analysis.md`, findings PA-01…PA-30) — every one of those 30 is now closed, accepted, or by-design. This pass hunts for **new** issues only: bugs, missing checks/validation, dead code, error-handling gaps, and test gaps. It does **not** re-litigate the 30 already resolved.
**Date:** 2026-10-25
**Method:** Fresh read of the calc/persistence/model layer plus a targeted sweep of the UI layer; every load-bearing claim was verified against source (grep + read). Where v1 made a blanket claim it was re-checked — one of them (the "no `fatalError`" assertion) turns out to be inaccurate, and is corrected in PA-32.
**Disposition:** This pass began **analysis-only**, but **PA-31, PA-32, PA-33, PA-36 and PA-37 have since been implemented, built, tested, and approved** by the user (see *Handover* below); the remaining three findings (PA-34, PA-35, PA-38) stay open candidates. All eight are Low/Info — **none is a High/Medium defect** — so the live calc/persistence paths are sound. PA-33, PA-36 and PA-37 touch a view or the share card and were **reported under `UI_RESTRICTIONS.md` before changing** (approved; no restriction tripped). No accepted/by-design item (age inert under Katch-McArdle, the live `normalizeAfter*Change`, the PA-01 device sentinel) was re-raised.

---

## Summary table

Ref | Title | Category | Severity | Status | Location
--- | --- | --- | --- | --- | ---
**PA-31** | `print()` still used for preset error logging — PA-16 migrated 2 of 3 logging files | Error handling | Low | **Done** | `MacroSplitOptionsModelCollection.swift` (see *Handover*)
**PA-32** | `fatalError` at `SwiftDataContainer:25` — legitimate trap, but contradicts v1's "no `fatalError`" claim | Error handling / doc accuracy | **Info** | **Done — trap replaced by recovery** | `SwiftDataContainer.swift` (see *Handover*)
**PA-33** | `ActivityLevel.displayShortName` is now an exact duplicate of `displayName` (post PA-10) | Dead code / UI | Low | **Done** | `ActivityLevel.swift:57-65`, `UISectionSummaryValueActivityLevel.swift:21,27`
**PA-34** | `ConfigKeys` — 6 unused string constants (pre-SwiftData leftover) | Dead code | **Info** | **Open (candidate)** | `Config/ConfigKeys.swift`
**PA-35** | Unreachable `guard caloriesAdjustedPerDay >= 0` + misleading comment | Dead code | **Info** | **Open (candidate)** | `CalculateMacros.swift:20`
**PA-36** | Share card renders two identical "Macro Split" / "Macro Preset" lines | Share / poor code | Low | **Done** | `ProfileViewModel.swift:284-285`, `ShareResultsModel.swift:139-140`
**PA-37** | `.estimate` body fat shows "N/A" or a stale manual value in the share card; untested | Share / test gap | Low | **Done** | `CalculateLeanBodyMass.swift:25-33`, `ShareResultsModel.swift:184-188`, `ShareResultsModelTests.swift`
**PA-38** | Vestigial macro-edit handlers + stale "move these…" comment + unused `swiftDataContainer` property | Dead code / hygiene | **Info** | **Open (candidate)** | `MacroEditViewPage.swift:29`, `MacroOptionsListViewPage.swift:18-31`, `TDEEApp.swift:15`

**Severity tally:** Low 4 · Info 4 — **8 findings**. Outstanding: **3** — PA-31, PA-32, PA-33, PA-36 and PA-37 are now **Done** (built, tested, approved; see *Handover*); the other three open candidates are PA-34, PA-35 and PA-38. No High/Medium findings. **Carried forward from v1:** all 30 closed/accepted/by-design (PA-02…PA-30 Done; PA-01, PA-17 Accepted; PA-24 By Design; PA-20, PA-22 Confirmed correct).

---

## Detailed findings

### Outstanding

> New findings from the 2026-10-25 re-audit. All are Low/Info; the live calculation and persistence paths are sound, so there is nothing user-breaking to fix first.

#### PA-31 — `print()` still used for preset error logging (PA-16 gap)
**Location:** `TDEEShared/Models/Macros/MacroSplitOptionsModelCollection.swift:44,56,89,137`
PA-16 (Done 2026-10-24) migrated **7** failure-path `print()` calls to `os.Logger` — 4 in `ProfileStore` and 3 in `ProfileViewModel` — but a third logging site was missed: `MacroSplitOptionsModelCollection` still `print`s its 4 failure paths (load / reset / save / delete) and has neither `import os` nor a `Logger`. A full-tree grep confirms these are the **only** `print()` calls left anywhere in `TDEE` / `TDEEWatch` / `TDEEShared` (excluding tests). In a release build they are lost and give the user no signal that a preset persist/reset failed.
**Recommendation:** Mirror PA-16 exactly — add `import os` and a `private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DaveBerryUk.TDEE", category: "MacroSplitOptionsModelCollection")`, then route the 4 calls through it with identical message content.
**Status: Done (2026-10-26).** The 4 paths route through `os.Logger` and set a non-blocking `notice`; a phone `NoticeBanner` surfaces it. Built, tested (`TDEETests` 227/0), and approved. See *Handover*.

#### PA-32 — `fatalError` at `SwiftDataContainer:25` (corrects a v1 claim)
**Location:** `TDEEShared/Models/SwiftData/SwiftDataContainer.swift:25`
The **only** `fatalError` / `precondition` / `assert` / `TODO` / `FIXME` in the `TDEE` + `TDEEWatch` + `TDEEShared` tree (excluding tests) is here:
```swift
} catch {
    fatalError("Failed to initialize SwiftData container: \(error)")
}
```
This is a **legitimate, defensible launch trap** — an app with no store cannot run, so a hard stop is reasonable — but it directly contradicts v1's "Confirmed correct" claim *"No `fatalError` / `precondition` / `assert` / `TODO` in the codebase — no crash-on-init traps."* That claim was inaccurate.
**Recommendation:** Accept the trap as by-design (or, if a clean-failure surface is ever wanted, log-and-fallback instead of trapping). No code change required; the action item is to **correct v1's blanket claim** so the "no traps" statement is not relied upon.
**Status: Done (2026-10-26).** The trap is replaced by a `LaunchStore`-driven recovery screen (the v1 "no `fatalError`" claim is now moot). Built, tested (`TDEETests` 227/0), and approved. See *Handover*.

#### PA-33 — `displayShortName` is now an exact duplicate of `displayName`
**Location:** `TDEEShared/Models/SwiftData/ActivityLevel.swift:57-65`; `TDEE/ViewsSectionSummaryValues/UISectionSummaryValueActivityLevel.swift:21,27`
After PA-10 collapsed `ActivityLevel` from 9 cases to the 5 canonical ones, `displayShortName` (lines 57-65) became **byte-for-byte identical** to `displayName` (lines 46-54) — the "short" form and the full form now converge on the same strings for all five levels. `UISectionSummaryValueActivityLevel` is the **lone consumer** of `displayShortName` (a `Text` at line 21 and its `.accessibilityValue` at line 27); every other call site in the tree uses `displayName`. The two are now redundant aliases.
**Recommendation:** Collapse `displayShortName` onto `displayName` (delete the duplicate property; point the view at `displayName`). Pure cleanup, no behaviour change.
**Status: Done (2026-10-26).** Low. Touched a view (`UISectionSummaryValueActivityLevel`) → reported under `UI_RESTRICTIONS.md` and approved; `displayShortName` deleted, the view now uses `displayName`. Behaviour-preserving — the rendered string is unchanged.

#### PA-34 — `ConfigKeys` is dead
**Location:** `TDEEShared/Config/ConfigKeys.swift`
A `struct` of 6 unused string constants (`gender`, `age`, `height`, `weight`, `activityLevel`, `bodyFatPercentage`) — the `UserDefaults` keys from the pre-SwiftData persistence era. A full-tree grep returns **zero** references outside the file's own definition.
**Recommendation:** Delete the file. No callers, no behaviour change.
**Status: Open (candidate).** Info.

#### PA-35 — Unreachable `guard caloriesAdjustedPerDay >= 0`
**Location:** `TDEEShared/Calculations/Extensions/CalculateMacros.swift:20`
`calculateMacros(result:)` begins with:
```swift
// Guard against negative calorie values
guard caloriesAdjustedPerDay >= 0 else { /* zero the macros; return */ }
```
but `caloriesAdjustedPerDay = Int(result.adjustedCalories)`, and `adjustedCalories` is **only ever** set via `adjustCalories(base:)` (`CalculatorTdee.swift:33`), whose three branches (`.maintain` / `.bulk` / `.cut`) all return `max(0, …)` (`CalculateAdjustCalories.swift:18,20,22`). The invariant the guard defends is already guaranteed upstream, so the branch can never fire and its comment is misleading.
**Recommendation:** Delete the guard and its comment (or keep it as an explicit belt-and-braces invariant but drop the "negative values" framing). No behaviour change.
**Status: Open (candidate).** Info.

#### PA-36 — Share card renders two identical "Macro Split" / "Macro Preset" lines
**Location:** `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift:284-285`; `TDEEShared/Models/ShareResultsModel.swift:139-140,207-210`
`createShareResultsModel(result:)` passes the **same expression** for both fields:
```swift
macroMethodName:  selectedMacro?.name ?? "Custom",
macroPresetName:  selectedMacro?.name ?? "Custom"
```
so `shareText` always emits two identical lines:
```
- Macro Split: Balanced
- Macro Preset: Balanced
```
The two fields read as distinct concepts (a split *algorithm* vs a *preset name*), but they are equal in production; for an unmatched `selectedMacroId` both read "Custom". This is the same "card-vs-model" redundancy class as PA-27.
**Recommendation:** Either drop one of the two share lines, or feed them genuinely different values. The image `ShareCardView` uses only `macroPresetText`, so the duplication is text-only. **Share-card display** → report under `UI_RESTRICTIONS.md`.
**Status: Done (2026-10-26).** Low. Reported under `UI_RESTRICTIONS.md` and approved — collapsed to a single "Macro Preset" line; the redundant `macroSplitMethodText` field / `macroMethodName` param removed (the share image already used only `macroPresetText`).

#### PA-37 — `.estimate` body fat reads a stale / "N/A" value in the share card; untested
**Location:** `TDEEShared/Calculations/Extensions/CalculateLeanBodyMass.swift:25-33`; `TDEEShared/Models/ShareResultsModel.swift:184-188`; `TDEETests/ShareResultsModelTests.swift` (no `.estimate` case)
For `.estimate`, lean body mass is derived from weight/height/gender (`0.407·w + 0.267·h − 19.2` male / `0.252·w + 0.473·h − 48.3` female) and **`bodyFatPercentage` is never populated** — only `.manualEntry` writes it, via the entry views. But `ShareResultsModel.bodyFatText` reads `profile.bodyFatPercentage` regardless of method:
```swift
if profile.bodyFatPercentageMethod != .omit, profile.bodyFatPercentage > 0 {
    self.bodyFatText = formatAsInteger(profile.bodyFatPercentage) + "%"
} else {
    self.bodyFatText = "N/A"
}
```
So an `.estimate` profile prints **"N/A"** on a fresh profile (default `bodyFatPercentage` is `0`) or — worse — a **stale manual value**, because `bodyFatPercentage` is a persisted field that the `.manualEntry → .estimate` switch does **not** zero (`bodyFatPercentageMethod.didSet` only toggles `bodyFatPercentageShowManualEntry`, it never clears the value). The card can therefore show a body-fat % the estimate never used. The on-screen rows already gate on the method (`UISectionSummaryValueBodyFat` and `WatchBodyFatView` both check `method == .manualEntry`); the share card is the odd one out. `ShareResultsModelTests` cover `.omit`→"N/A" and `.manualEntry`→"15%"/zero→"N/A" but have **no `.estimate` case**, so the gap is untested.
**Recommendation:** Gate `bodyFatText` on `bodyFatPercentageMethod == .manualEntry` (matching the on-screen rows), and add a `.estimate`→"N/A" test. **Share-card display** → report under `UI_RESTRICTIONS.md`.
**Status: Done (2026-10-26).** Low. Reported under `UI_RESTRICTIONS.md` and approved — `bodyFatText` now gated on `bodyFatPercentageMethod == .manualEntry`; a `.estimate`→"N/A" test added to `ShareResultsModelTests`.

#### PA-38 — Vestigial macro-edit handlers, a stale comment, and an unused property
**Location:** `TDEE/Pages/MacroEditPage/MacroEditViewPage.swift:29`; `TDEE/Pages/MacroOptionsListPage/MacroOptionsListViewPage.swift:18-31`; `TDEE/TDEEApp.swift:15`
Three small dead/legacy items in the macro-edit flow:
- **(a)** `MacroEditViewPage.handleOnDelete()` (no-arg, `private`) has **zero call sites** — the real delete goes through `DeleteConfirmationSheet.onConfirm` → `collection.remove(editMacro)` (`MacroEditViewPage.swift:114`).
- **(b)** The page-level `MacroOptionsListViewPage.handleOnDelete(item:)` / `handleOnSave(item:)` are also **uncalled** (the card/row subviews define and call their *own* copies), and the comment directly above them reads `// move these into a collection handler` — already effectively done, since `collection.remove` / `collection.update` *are* the handlers. A trailing empty `//` block sits below them too.
- **(c)** `TDEEApp.swift:15` `private let swiftDataContainer = SwiftDataContainer.shared` is an **unused stored property** — `SwiftDataContainer.shared` is a `static let`, alive for the process regardless, so the property adds nothing.
**Recommendation:** Delete the three uncalled handlers and the unused property; remove the stale "move these into a collection handler" comment and the empty comment block. No behaviour change.
**Status: Open (candidate).** Info.

---

## Confirmed correct (no issues found)

These areas were audited this pass and found sound — included so the scope is explicit:

- **`MacroSplitOptionsModelCollection` CRUD + persistence queue is correct** — `add`/`update`/`remove`/`move` reindex ordinals, `remove` guards `items.count > 1`, and the `enqueue`/`pending`/`flush` chain serialises saves so a delete can't overtake a save. (Only its logging is a gap — PA-31.)
- **`ProfileRepository` / `ProfileStore` are sound after PA-13/PA-14** — active-profile preservation across `load()`/`add()`/`rename()`, the Main/last-profile delete guards, and UOM round-trip all hold.
- **`adjustCalories` clamps to `max(0, …)` on all three branches** — the non-negative invariant holds, which is exactly why PA-35's guard is unreachable.
- **`MacroEditViewPage` guards are correct** — Save is disabled when `name.isEmpty` or `protein+carbs+fats != 100`; Delete is disabled when `items.count <= 1` (mirrors the collection's own guard).
- **Weight Classic/New section variants diverge intentionally, not accidentally** — `WeightClassicSectionView` (expand/collapse panel + wheel) and `WeightNewSectionView` (inline switcher + text-field/wheel) are two deliberate layouts switched by `InputStyleManager`; validation is consistent (`isNaN || == 0`) and there is no copy-paste drift between the pair.
- **Watch wheels / range clamping remain in-range** — `WatchCalorieAdjustmentView` and `WatchRanges` clamp through the non-optional `adjustmentMin`/`adjustmentMax` bounds added in PA-23.
- **BMR unit handling is correct** (carried from v1) — metric kg/cm is the source of truth; UOM is display-only.
- **Katch-McArdle is age-inert by design** (carried from v1 / memory) — under `.estimate`/`.manualEntry` age has no effect on LBM; not to be "fixed."

> **Re-checked v1 claim:** v1's "no `fatalError`/`precondition`/`assert`/`TODO`" bullet is **inaccurate** — see PA-32. The single `fatalError` at `SwiftDataContainer:25` is a defensible launch trap, so the "no crash-on-init *traps we should worry about*" intent still largely holds; only the blanket statement needs correcting.

---

## Prioritisation

All eight are Low/Info; a single cleanup pass covers them. Suggested order:

1. **PA-31** — logging-only migration that mirrors the already-done PA-16; the one finding with a real (if minor) user impact, because the 4 preset-persist failure paths are lost in release. Safe to apply with no `UI_RESTRICTIONS.md` approval.
2. **PA-37** — the share card can print a body-fat % the `.estimate` path never used; user-visible and untested. (Report first — share card.)
3. **PA-36** — the duplicated "Macro Split" / "Macro Preset" share line. (Report first — share card.)
4. **PA-33** — collapse the now-identical `displayShortName` onto `displayName`. (Report first — touches a view.)
5. **PA-34 / PA-35 / PA-38** — pure dead-code / hygiene removals (`ConfigKeys`, the unreachable `>= 0` guard + comment, the vestigial handlers + stale comment + unused property). No approval needed.
6. **PA-32** — correct v1's "no `fatalError`" claim; the trap itself is accepted by-design. No code change.

**No High/Medium findings** — nothing blocks a release; all items are optional cleanups.

---

### Constraints honoured
- **Analysis-only for PA-34, PA-35, PA-38** — those three remain untouched. **PA-31, PA-32, PA-33, PA-36 and PA-37 have since been implemented**; see *Handover* below.
- **`MacroSplitOptionsNormalization.swift`** was not touched (DO-NOT-EDIT); PA-06's accepted split between the live instance `normalizeAfter*Change(_:)` and the `init`/`clone` `normalizeAll`/`adjustByDiff` was not re-raised.
- **`UI_RESTRICTIONS.md`:** PA-33, PA-36 and PA-37 each touch a view or the share card, so each was **reported for approval before changing** (and approved); no `.pickerStyle` / option-case / `UILayoutExpandingPanel` / animation-parameter change was made — PA-33 is behaviour-preserving (identical strings), and PA-36/PA-37 change share-card *text* only.
- **Accepted / by-design items not re-raised:** age inert under Katch-McArdle, the live `normalizeAfter*Change`, and the PA-01 device height/weight `0` sentinel were all left as-is.

---

## Handover — PA-31 & PA-32 implementation (2026-10-25)

This pass was analysis-only, but **PA-31 and PA-32 have since been implemented** at the user's request — *"PA-31 and PA-32 should display a friendly dialog message for fatal errors, explaining the error and a potential resolution, in fact this should be done on all launch potential fatal errors."* Two design decisions were settled with the user before coding: **recovery = "Try Again" + a confirm-gated "Reset stored data"** (a wipe-and-reopen, the only path that recovers a corrupt/incompatible store), and **scope = a full-screen dialog for the launch trap, plus non-blocking notices for the 4 non-fatal preset paths** (the graceful in-memory fallback is kept). The source for both was **written but not yet built or tested**; that was the state picked up on 2026-10-26, when the test was added, both schemes were built, `TDEETests` ran green (227/0), and the three new UI surfaces were approved (see *Done* below).

**Done (source written):**
- **PA-32** — the sole launch trap (`fatalError` in `SwiftDataContainer`, now gone) is replaced by a `LaunchStore` coordinator that owns the open and two recoveries: `retry()` re-opens the existing store; `reset()` wipes it via `SwiftDataStoreFile.removeAll()` and reopens a fresh one. `SwiftDataContainer.shared` is now crash-safe (on-disk in production, in-memory under test, with a logged in-memory fallback and a `try!` last resort), and a new throwing `makeStore(reset:)` is the app path. Both apps were restructured to branch on `launch.outcome`, so the phone/watch models are built once from a live repository inside a `PhoneLaunchView` / `WatchLaunchView` (only on `.ready`). `LaunchErrorView` (themed, phone) and `WatchLaunchErrorView` (watch, `@State`-driven confirm screen) render the `LaunchFailure` message + resolution.
- **PA-31** — `MacroSplitOptionsModelCollection` logs its 4 failure paths (load / reset / save / delete) through `os.Logger` and sets a transient `notice`; `ContentView` surfaces it as an animation-free top `NoticeBanner`.

**Scope note:** the watch gets the launch recovery screen and the shared `os.Logger` fix (via the model), but **not** the non-blocking banner — its compact `List` surface makes a banner awkward, so the notice was scoped to the phone.

**New / changed files** (Xcode 16+ synchronised folders → they auto-compile, no `project.pbxproj` edits):
- *New:* `SwiftDataStoreFile.swift`, `LaunchStore.swift`, `TDEE/ViewsLaunch/LaunchErrorView.swift`, `TDEE/ViewsLaunch/NoticeBanner.swift`, `TDEEWatch/views/WatchLaunchErrorView.swift`.
- *Rewritten:* `SwiftDataContainer.swift`, `TDEE/TDEEApp.swift`, `TDEEWatch/app/TDEEWatchApp.swift`.
- *Edited:* `MacroSplitOptionsModelCollection.swift` (PA-31), `TDEE/ContentView.swift` (PA-31 banner).

**Done (2026-10-26, after the 2026-10-25 handover):**
1. `TDEETests/LaunchStoreTests.swift` written — 7 Swift Testing cases drive `.ready`/`.failed` through the injected `opener` and assert `retry()` / `reset()` pass `reset: false` / `reset: true` (plus lazy-opener, transient-failure recovery, and the escalated post-reset message).
2. `TDEE` and `TDEEWatch` schemes both build (`** BUILD SUCCEEDED **`).
3. `TDEETests` run: 227 passed, 0 failed (incl. the 7 new `LaunchStoreTests`).
4. The three new UI surfaces reported under `UI_RESTRICTIONS.md` rule 5 and **approved** by the user — additive and animation-free, so no restriction is tripped.
5. Committed on 2026-10-26 (branch `features/investigation`) — all changes staged together, with the `LaunchStoreTests` addition and these three compile fixes.

**Compile fixes applied to the 2026-10-25 source** (it was "written, not yet built"; these were the blockers to a green build):
- `NoticeBanner.swift:60` + `LaunchErrorView.swift:87` — the preview `ThemeManager(defaults: UserDefaults(suiteName: …))` needs a non-optional; added `!`, matching the existing previews (`ContentView` / `ThemeView` / `SidebarView`).
- `LaunchStore.swift` — the templated `init(underlying:afterReset:)` suppresses the synthesized memberwise init that the `notAttempted` placeholder needs; added an explicit `init(userMessage:detail:underlying:)`.

**PA-34, PA-35 and PA-38 remain open candidates** (untouched).

---

## Handover — PA-33, PA-36 & PA-37 implementation (2026-10-26)

At the user's request (*"work through 33, 36, 37"*), the three remaining UI-touching open candidates were implemented. Each was first reported under `UI_RESTRICTIONS.md` rule 5 (file / reason / proposed change / approval request); the user approved all three and, for PA-36, chose to keep the "Macro Preset" label over "Macro Split".

**Done:**
- **PA-33** — deleted the duplicate `ActivityLevel.displayShortName` (byte-for-byte identical to `displayName` after PA-10) and pointed its lone consumer, `UISectionSummaryValueActivityLevel` (the `Text` and its `.accessibilityValue`), at `displayName`. Behaviour-preserving — the rendered string is unchanged.
- **PA-36** — collapsed the two identical share-card lines to a single "Macro Preset" line. Removed the now-redundant `macroSplitMethodText` field and the `macroMethodName` init param from `ShareResultsModel` (and the matching `createShareResultsModel` argument in `ProfileViewModel`); the share image already used only `macroPresetText`, so the duplication was text-only. The two `ShareResultsModelTests` macro cases were pointed at `macroPresetText` and their labels updated.
- **PA-37** — gated `ShareResultsModel.bodyFatText` on `bodyFatPercentageMethod == .manualEntry` (matching the on-screen `UISectionSummaryValueBodyFat` / `WatchBodyFatView` rows), so an `.estimate` profile reads "N/A" instead of a stale manual value; added a `.estimate`→"N/A" regression test.

**Build & test (2026-10-26):** `TDEE` and `TDEEWatch` schemes both build (`** BUILD SUCCEEDED **`); `TDEETests` run green — **228 passed, 0 failed** (the prior 227 plus the one new `.estimate` case). No `UI_RESTRICTIONS.md` restriction tripped: PA-33 is behaviour-preserving, and PA-36/PA-37 change share-card *text* only (no picker / option-case / panel / animation change).
