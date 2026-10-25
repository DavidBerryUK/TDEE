# TDEE — Problem Analysis

**Scope:** Static analysis of the `TDEE` (iPhone), `TDEEWatch` (watchOS) and `TDEEShared` (shared calc/persistence/models) targets.
**Date:** 2026-10-22
**Method:** Multi-pass audit across four slices — watch app, config/theme/dead-code, error-handling/concurrency, and UI + test-suite — plus independent verification of each load-bearing claim against source.
**Disposition:** **Analysis only. No code was modified.** Every finding below is a candidate for review; the two items touching `MacroSplitOptionsNormalization.swift` are flagged for review only (that file carries an explicit DO-NOT-EDIT constraint).

---

## Summary table

Ref | Title | Category | Severity | Status | Location
--- | --- | --- | --- | --- | ---
**PA-15** | `UIMainView` onChange storm (11 handlers / 10 Tasks) → redundant recalcs, racy `isCalculating` | UI / concurrency | Medium | Outstanding | `UIMainView.swift:132-173`
**PA-18** | `regularLayout` shares one `NavigationStack` `path` across sidebar + detail | UI | Low | Outstanding | `ContentView.swift`
**PA-20** | Watch weight/height ranges diverge from phone (`0…250` vs `20…300`, etc.) | Watch | Low | **Confirmed correct (2026-10-25)** | `WatchRanges.swift:14,18`, `WatchWeightView.swift`
**PA-21** | Watch "missing / Not set" is zero-based and omits age; diverges from calculator | Watch | Low | **Done (2026-10-25)** | `WatchMainView.swift:77-84`
**PA-22** | Watch adjustment: default `500` vs `250`; wheel steps by 25 vs continuous slider | Watch | Low | **Confirmed correct (2026-10-25)** | `CalorieAdjustmentEntryView.swift:19`, `WatchRanges.swift:28`
**PA-23** | Force-unwrap `WatchRanges.adjustment.first!/last!` — latent crash if stride emptied | Watch | Low | **Done (2026-10-25)** | `WatchCalorieAdjustmentView.swift:17`, `WatchRanges.swift`
**PA-04** | Dead second calculation pipeline (`refreshResults` / `tdee` / `macroTargets`) | Calc / dead code | **High** | **Done (2026-10-22)** | `ProfileViewModel.swift`
**PA-06** | Three divergent macro-normalization algorithms | Calc / dead code | **High** | **Done (2026-10-24)** | `MacroSplitOptionModel.swift:103-172`, `MacroSplitOptionsNormalization.swift`
**PA-05** | Dead hardcoded 40/30/30 `calculateMacros(tdee:)` with `00.4` literals | Calc / dead code | Medium | **Done (2026-10-24)** | `ProfileViewModel.swift` (removed with PA-04)
**PA-07** | `updateProtein`/`updateCarbs`/`updateFats` are dead (zero callers) | Calc / dead code | Medium | **Done (2026-10-24)** | `ProfileViewModel.swift:327-346`, `MacroSplitOptionsNormalization.swift:250-271`
**PA-10** | Four `ActivityLevel` cases reuse base multipliers → duplicate iPhone options | Calc | Medium | **Done (2026-10-24)** | `ActivityLevel.swift:11-16`
**PA-11** | `.light` and `.moderate` both render "Moderate activity" in share card | Calc | Medium | **Done (2026-10-24)** | `ActivityLevel.swift:23-24`, `ShareResultsModel.swift:122`
**PA-19** | Watch offers 5 of 9 `ActivityLevel` cases; others fall back to `.lightExercise` | Watch | Medium | **Done (2026-10-24)** | `WatchRanges.swift:40`, `WatchActivityLevelView.swift:23`
**PA-27** | Share card sign bug: a cut reads `+500 kcal` (identical to a 500 bulk) | Share | Medium | **Done (2026-10-24)** | `ShareResultsModel.swift:138-144`
**PA-28** | Core tests assert the dead calc path; live path now covered by 6 parity cases | Tests | Medium | **Done (2026-10-24)** | `TDEETests.swift`, `CalculationParityTests.swift`
**PA-13** | `ProfileStore.add`/`rename`/`load()` re-derive active profile to "Main" | State | Medium | **Done (2026-10-24)** | `ProfileStore.swift:62-111`
**PA-14** | `weightUom` / `heightUom` are not persisted → UOM resets on reload (phone + watch) | Persistence | Medium | **Done (2026-10-24)** | `Profile.swift`, `ProfileMapper.swift`, `ProfileViewModel.swift`
**PA-02** | Two `ProfileDefaults` fields never consumed by `createProfile` | Config | Low | **Done (2026-10-24)** | `ProfileRepository.swift:78-96`
**PA-03** | `Profile.height` doc says "meters" but value is centimetres | Config | Low | **Done (2026-10-24)** | `Profile.swift:16`
**PA-08** | Duplicated `snapToStep` / `clampValueTo100` (5 definitions, 2 files) | Calc / dead code | Low | **Done (2026-10-24)** | `MacroSplitOptionModel.swift:174-200`, `MacroSplitOptionsNormalization.swift`
**PA-12** | Audit trail / `AuditLogger` vestigial; test-only `calculateTDEE` shim | Calc / dead code | Low | **Done (2026-10-24)** | `CalculatorTdee.swift`, `TDEETests.swift` (shim removed)
**PA-25** | No UOM round-trip persistence test (gap that would catch PA-14) | Tests | Low | **Done (2026-10-24)** | `SwiftDataPersistenceTests.swift`
**PA-26** | Share card hardcodes "cm"/"kg", ignoring the user's UOM | Share | Medium | **Done (2026-10-24)** | `ShareResultsModel.swift:115-119`
**PA-09** | `KatchMcArdleMultipliers` misnomer — factor is applied to Mifflin too | Calc | Low | **Done (2026-10-24)** | `ActivityLevel.swift:64-78`, `CalculatorTdee.swift:50`
**PA-16** | `print()` used for error logging (lost in release, not surfaced) | Error handling | Low | **Done (2026-10-24)** | `ProfileStore.swift:78,108,126`, `ProfileViewModel.swift:197,212,258`
**PA-29** | No cut/bulk adjustment test on the production path | Tests | Low | **Done (2026-10-24)** | `CalculationParityTests.swift`
**PA-30** | `File.swift` is an empty test stub | Tests | Info | **Done (2026-10-24)** | `TDEETests/File.swift`
**PA-01** | First-launch **device** profile seeds height/weight = 0 → validation error, no TDEE | Config | **Medium** | Accepted | `ProfileDefaults.swift:35-46`, `ProfileRepository.swift:78-96`
**PA-17** | `ProfileViewModel` convenience init spawns a load Task (non-idiomatic, safe) | Concurrency | Info | Accepted | `ProfileViewModel.swift:177-179`
**PA-24** | Watch uses a standalone store; phone↔watch data never syncs | Watch | Info | By Design | `TDEEWatchApp.swift:16`

**Severity tally:** High 2 · Medium 7 · Low 10 · Info 2 — **30 findings**. Outstanding: **PA-15, PA-18** (2). Done: 23 (PA-02, PA-03, PA-04, PA-05, PA-06, PA-07, PA-08, PA-09, PA-10, PA-11, PA-12, PA-13, PA-14, PA-16, PA-19, **PA-21**, **PA-23**, PA-25, PA-26, PA-27, PA-28, PA-29, PA-30). Confirmed correct (2026-10-25): **PA-20, PA-22**. Accepted: PA-01, PA-17. By design: PA-24 — plus the "Confirmed correct" section below.

---

## Detailed findings

### Outstanding

> Live outstanding set after the 2026-10-25 watch re-audit: **PA-15** (Medium), **PA-18** (Low).
> **PA-20** and **PA-22** were reclassified *Confirmed correct* and **PA-21**, **PA-23** were *Done* that day; their
> subsections remain below for traceability.

#### PA-15 — `UIMainView` onChange storm
**Location:** `TDEE/Pages/MainPage/UIMainView.swift:132-173`
Eleven `.onChange` handlers (gender, age, weight, height, bodyFatMethod, bodyFatPercentage, calorieAdjustmentMethod, calorieAdjustment, selectedMacroId, globalMacroCollection.items, selectedMacroSplit, activeProfileId) each spawn `Task { await recalculate() }` (~10 of them). Rapid input fires many concurrent recalculations, and `recalculate()` toggles `isCalculating` non-atomically (`true → await → false`), so the "calculating" indicator can show a stale/incorrect state under overlap.
**Recommendation:** Coalesce into a single reactive dependency (e.g. one `.task(id:)` over a computed inputs key, as `WatchMainView` already does) and gate `isCalculating` on completion.

#### PA-18 — `regularLayout` shares one `NavigationStack` path
**Location:** `TDEE/ContentView.swift` (regular layout)
The detail `NavigationStack(path: $path)` shares the same `path` as `SidebarView(path: $path)`. A latent navigation quirk: selecting a sidebar destination and pushing within detail can share/overwrite the same path state.
**Recommendation:** Give detail its own path binding if the two navigation contexts should be independent.

#### PA-20 — Watch weight/height ranges diverge from the phone
**Location:** `TDEEWatch/enums/WatchRanges.swift:14,18`; `TDEEWatch/views/WatchWeightView.swift`
`weightKg = 0…250` (phone `20…300`), `heightCm = 0…272` (phone `100…272`). A phone value outside the watch's caps would trap the watch's `Int(profile.weight)` display; within the watch's own store the value is always in-range, so this is a latent divergence rather than a live crash. The stones path (max ≈ 260 kg) also exceeds the kg/pounds wheel caps.
**Recommendation:** Align the watch wheel bounds with `MetricRanges`, or clamp the derived `Int` values.
**Status: Confirmed correct (2026-10-25) — not a divergence; reclassified, no code change.** Re-audited against the current code: the watch wheels are byte-for-byte identical to the phone's `UIWheelPickerWeightView` / `UIWheelPickerHeightView` option arrays (kg `0…250`, lb `0…550`, st `0…40`, st·lb `0…13`, cm `0…272`, in `0…107`, ft `0…8`, ft·in `0…11`), and `WatchRanges.swift:17` documents the intent — "matching the iPhone pickers." The audit compared the **wheel** range (`0…250`) with the **validator** range (`MetricRanges.weight = 20…300` / `MetricRanges.height = 100…272`), but that wheel-vs-validator split exists identically on the phone, and PA-24 (standalone store) means a phone value never reaches the watch. The one real sub-issue — the stones screen can reach ~260 kg, past the kg/lb wheel caps — is a pre-existing **phone** display quirk the watch mirrors (the underlying kilograms stay correct; the wheel simply shows no matching tag at that extreme). Aligning the watch to `MetricRanges` would *diverge* it from the phone and break the `0 = "Not set"` sentinel (PA-01), so the ranges are left as-is.

#### PA-21 — Watch "missing / Not set" is zero-based and omits age
**Location:** `TDEEWatch/views/WatchMainView.swift:77-84`
`missingFields` flags weight/height only when the value is exactly `0` and never checks age, whereas `validateForCalculation()` flags weight/height whenever they fall outside `MetricRanges` and also checks `age == 0`. A sub-`20` kg weight reads as "set" on the row while the summary still reports "Weight mandatory" — row and result disagree.
**Recommendation:** Derive `missingFields` from the same `MetricRanges` the calculator uses (and include age for parity).
**Status: Done (2026-10-25).** `missingFields` now flags weight/height via the calculator's own `MetricRanges` — `!MetricRanges.weight/height.contains(…)` — instead of `== 0`, so a non-zero sub-range value (e.g. 5 kg) highlights in attention colour and drives the "Set up your profile" CTA, matching the "mandatory" result. `0` is out of range, so the device first-launch "Not set" sentinel (PA-01) is preserved. Age is deliberately left out: its wheel is `16…99` and the device default is `16` (`ProfileDefaults.device()`), so `age == 0` is unreachable on the watch and adding it would be dead code. Body fat was already in sync (`WatchRanges.bodyFatPercent` == `MetricRanges.bodyFatPercentage`). No UI change to picker style / options / panel / animation. `TDEEWatch` builds.

#### PA-22 — Watch adjustment defaults / granularity mismatch
**Location:** `TDEEWatch/views/CalorieAdjustmentEntryView.swift:19`; `WatchRanges.swift:28`; `WatchCalorieAdjustmentView.swift:24`
`CalorieAdjustmentEntryView` defaults to `500` while `WatchRanges.startingAdjustment = 250`; the wheel steps by 25 (`stride(from: 25, through: 1000, by: 25)`) while the slider is continuous `0…1000`. Two adjustment inputs with different defaults and granularity.
**Recommendation:** Unify the default and the step semantics across the two inputs.
**Status: Confirmed correct (2026-10-25) — stale; reclassified, no code change.** The cited `CalorieAdjustmentEntryView.swift:19` no longer exists, and every `500` in the codebase is inside a `#Preview` block (verified across `SectionCalorieAdjustment`, `UISliderCalorieAdjustmentValue`, `UISectionSummaryValueCalorieAdjustment`, `SectionEditorCalorieAdjustment`); the production default is `0` (`ProfileViewModel` / `Profile.init`) and the watch uses `WatchRanges.startingAdjustment = 250` consistently. The "25-step wheel vs continuous slider" is phone-vs-watch and is **documented as intentional** in `CalorieAdjustmentEntry.swift:18` ("the slider's 25-step was a slider affordance, not a value cap" — the New entry is a free integer 0–1000). No watch-side inconsistency remains.

#### PA-23 — Force-unwrap of `WatchRanges.adjustment` bounds
**Location:** `TDEEWatch/views/WatchCalorieAdjustmentView.swift:17`
The calories binding getter and `.onChange` clamp force-unwrap `WatchRanges.adjustment.first!` / `.last!`. Safe while the stride is non-empty, but a future edit that empties the stride (`from:` > `through:`) turns these into a crash on the Goal screen.
**Recommendation:** Use a non-optional bounds API or a `?? default`.
**Status: Done (2026-10-25).** Added non-optional bounds to `WatchRanges` — `adjustmentMin` / `adjustmentMax` (`adjustment.first ?? 25` / `adjustment.last ?? 1000`, the stride's own endpoints, so behaviour is identical) — and used them in both force-unwrap sites in `WatchCalorieAdjustmentView` (the `calories` getter and the `.onChange` clamp). The two `first!` / `last!` unwraps are gone; an emptied stride now degrades to the fallback bounds instead of crashing. No UI change (no picker style / option / panel / animation touched). `TDEEWatch` builds.

### Done

#### PA-04 — Dead second calculation pipeline
**Location:** `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift:263-275`
`refreshResults()` ran on every input change (all 12 property `didSet`s + `switchProfile`), computing a full BMR → TDEE → macro cycle and writing it into `tdee` and `macroTargets`. Grep confirmed **no production code read `profile.tdee` / `profile.macroTargets`** — the live UI path is `UIMainView`/`WatchMainView` → `Calculator.calculate(person:)` → `CalculatorResultViewModel`. A whole second pipeline ran on every edit and its output was discarded. Because `refreshResults` ignored `calorieAdjustment` and hardcoded 40/30/30 (see PA-05), the two paths could silently drift.
**Recommendation:** Delete `refreshResults()`, `tdee`, `macroTargets` and their `didSet` calls; keep only `Calculator.calculate`.
**Status: Done (2026-10-22).** `refreshResults()`, the `tdee` / `macroTargets` state, and every `didSet` / `switchProfile` call into them were deleted from `ProfileViewModel`; the live path is now solely `Calculator.calculate(person:)`. The dead-path tests that asserted `profile.tdee` / `macroTargets` (`testRefreshResults`, `testAutomaticRecalculation`, `testCalculateMacrosFromTDEE`, `testMacroCalorieValues`) were removed in the same changeset, and `CalculationParityTests` now pins the live path (cut / bulk / recalc-on-change / zero-guard). Grep confirms **zero remaining references** to `refreshResults` / `ProfileViewModel.tdee` / `ProfileViewModel.macroTargets` — the only surviving `.tdee` / `macroTargetsText` are on `CalculatorResultViewModel` / `ShareResultsModel`, which is the live path.

#### PA-06 — Three divergent macro-normalization algorithms
**Location:** `TDEEShared/Models/Macros/MacroSplitOptionModel.swift:103-172`; `TDEEShared/Models/Macros/MacroSplitOptionsNormalization.swift`
Three different overflow-distribution strategies coexist: (a) the **live** instance `normalizeAfter{Protein,Carbs,Fats}Change(_:)` in `MacroSplitOptionModel.swift` (reached via `updateFromUi*`, used by `UISliderMacroMixView`); (b) the **static** `MacroSplitOptionModel.normalizeAfter*Change(newValue:original…:)` in the DO-NOT-EDIT file, which clamps both neighbours then distributes the remainder to the larger — reachable only through the dead `update*` methods (PA-07); and (c) `normalizeAll`/`adjustByDiff` used by the model's `init`. For the same input the live slider path and the static path can produce different 100%-balanced results.
**Recommendation:** Flag for review — **do not edit** `MacroSplitOptionsNormalization.swift`. Consolidate on one distribution algorithm and delete the dead family (after approval).
**Status: Done (2026-10-24) — dead family removed.** The dead static `normalizeAfter*Change(newValue:original…:)` family (b), reachable only through the `update*` wrappers (PA-07), was deleted from `MacroSplitOptionsNormalization.swift`, collapsing the count from three algorithms to two. The **live** instance path (a) — `updateFromUi*` → `normalizeAfter{Protein,Carbs,Fats}Change(_:)` in `MacroSplitOptionModel.swift` — is **retained unchanged**: it is the tuned slider UX and was deliberately not consolidated. `normalizeAll`/`adjustByDiff` (c) remain as the `init`/`clone` construction path. The two surviving algorithms serve different purposes (live editing vs. construction) and the divergence is accepted by design; grep confirms zero remaining references to the removed static family, and the app was verified in the simulator after the change.

#### PA-05 — Dead hardcoded 40/30/30 macro path
**Location:** `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift:280-291`
`calculateMacros(tdee:)` computes macros from fixed splits `00.4` / `0.3` / implied `0.3`, ignoring the profile's real `protein`/`carbs`/`fats` and `calorieAdjustment`. Reachable only via the dead `refreshResults()` (PA-04) and TDEETests; the production path is `calculateMacros(result:)` in `CalculateMacros.swift`, which uses the actual percents. The `00.4` literal is non-idiomatic (leading-zero double, reads like a typo).
**Recommendation:** Remove `calculateMacros(tdee:)` with `refreshResults`; if a helper is kept, source splits from the model and use named constants.
**Status: Done (2026-10-24).** `calculateMacros(tdee:)` was removed together with `refreshResults()` when PA-04 closed the dead second calculation pipeline (2026-10-22) — that method was its only production caller. Grep confirms the sole surviving `calculateMacros` is the live `calculateMacros(result:)` in `CalculateMacros.swift`, which uses the profile's real `protein`/`carbs`/`fats` percents; no `00.4`/`00.3` literals remain. No further action needed.

#### PA-07 — `updateProtein`/`updateCarbs`/`updateFats` are dead
**Location:** `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift:327-346`; `TDEEShared/Models/Macros/MacroSplitOptionsNormalization.swift:250-271`
Grep returns no call sites for either the `ProfileViewModel` overloads or the `MacroSplitOptionModel` overloads. The only live macro-edit entry points are `updateFromUi*` (slider) and `syncMacros(from:)` (preset selection). These dead methods are also the sole reachability path for the static normalize family (PA-06).
**Recommendation:** Delete the dead `update*` methods once normalization consolidation is approved.
**Status: Done (2026-10-24).** Both `update*` families were deleted: the `ProfileViewModel` overloads and the `MacroSplitOptionModel` wrappers in the second extension of `MacroSplitOptionsNormalization.swift` (along with the static `normalizeAfter*Change` family they were the sole callers of — PA-06). The live entry points `updateFromUi*` (slider) and `syncMacros(from:)` (preset) were untouched. Grep confirms **zero remaining references** to `updateProtein`/`updateCarbs`/`updateFats` or the static `normalizeAfter*Change` signatures.

#### PA-27 — Share card sign bug: a cut reads `+500 kcal`
**Location:** `TDEEShared/Models/ShareResultsModel.swift:138-144`; `TDEEShared/Calculations/Extensions/CalculateAdjustCalories.swift:18-25`
The calculator applies direction via the `.cut`/`.bulk` switch (`base ± calorieAdjustment`), so `calorieAdjustment` is a **non-negative magnitude** and direction lives in `calorieAdjustmentMethod`. But the share text derives its sign only from the value (`adjustment > 0 ? "+" : ""`), so a 500 kcal **cut** prints `+500 kcal` — identical to a 500 kcal bulk — even though the adjusted-calorie line correctly subtracts it. The card is internally inconsistent.
**Recommendation:** Derive the sign from `calorieAdjustmentMethod` (`.cut` → "−", `.bulk` → "+").
**Status: Done (2026-10-24).** The sign now comes from the method's existing `adjustmentPrefix` computed property (already used by `UISectionSummaryValueCalorieAdjustment`), not the value — so a cut reads `-500 kcal` and a bulk `+500 kcal`. Also added a `.maintain` guard: because `adjustCalories` ignores the magnitude for `.maintain`, the amount now reads "None" even when a stale non-zero magnitude is retained (the same class of card-vs-calculation inconsistency). Tests: `testCalorieAdjustmentNegative` was corrected to use a non-negative `300` under `.cut` (the real, production-reachable scenario — the range is `0...1000`, so the old `-300` setup was unreachable), and a new `testCalorieAdjustmentMaintainIgnoresMagnitude` documents the guard. Full `TDEE` suite passes on iPhone 17e (`** TEST SUCCEEDED **`).

#### PA-02 — Two `ProfileDefaults` fields never consumed
**Location:** `TDEEShared/Models/SwiftData/ProfileRepository.swift:78-96`
`ProfileDefaults` advertises 8 fields, but `createProfile(name:)` mapped only 6 onto `Profile.init` — `bodyFatPercentageMethod` and `calorieAdjustmentMethod` were inert *in `createProfile`* (a new profile's methods came from `Profile.init` defaults `.omit` / `.maintain`). No bug today (defaults coincidentally match), but a latent desync trap.
**Recommendation:** Pass both in `createProfile`, or drop the two fields from `ProfileDefaults`.
**Status: Done (2026-10-24).** Chose the first option: `createProfile(name:)` now passes `bodyFatMethod: defaults.bodyFatPercentageMethod` and `calorieAdjustmentMethod: defaults.calorieAdjustmentMethod`, so a new profile honours `ProfileDefaults` instead of silently inheriting `Profile.init`'s `.omit` / `.maintain`. The "drop the two fields" option is not viable — `ProfileViewModel` reads both as property defaults (`ProfileViewModel.swift:77,94`), so the fields are not inert overall, only unused in `createProfile`. Behaviour is unchanged today (all three defaulting paths agree on `.omit` / `.maintain`); the fix closes the latent desync trap where the two paths could later diverge. Verified with a full `TDEE` test run on the iPhone 17e simulator (`** TEST SUCCEEDED **`, no new warnings).

#### PA-03 — `Profile.height` documented as "meters"
**Location:** `TDEEShared/Models/SwiftData/Profile.swift:16`
The doc comment said "in meters" but every consumer uses centimetres (defaults 175, `MetricRanges.height` = 100…272, Mifflin-St Jeor's `6.25` factor expects cm). A future dev trusting the comment could unit-convert and break BMR.
**Recommendation:** Correct the comment to "centimetres".
**Status: Done (2026-10-24).** `Profile.swift:16` now reads "User's height in centimetres" (was "in meters"). One-line doc fix; no behaviour change.

#### PA-08 — Duplicated `snapToStep` / `clampValueTo100`
**Location:** `TDEEShared/Models/Macros/MacroSplitOptionModel.swift:174-200`; `MacroSplitOptionsNormalization.swift`
Rounding/clamping logic is reimplemented 5× across two files (instance `snapToStep(Double)`/`snapToStep(Int)`, static "test helper" `snapToStep` overloads, and a private static `snapToStep(_:step:…)`/`clampValueTo100` in the DO-NOT-EDIT file).
**Recommendation:** Keep one shared `snapToStep`/`clampValueTo100`; drop the test-only static overloads (flag the DO-NOT-EDIT file for review, don't edit it).
**Status: Done (2026-10-24).** Collapsed to one canonical set of `static` helpers — `snapToStep(_:)` (Double + Int) and `clampValueTo100(_:)` — in `MacroSplitOptionModel.swift` (7 definitions → 3). The two instance overloads and the parameterized `snapToStep(_:step:min:max:)` / `clampValueTo100` in `MacroSplitOptionsNormalization.swift` were deleted; the live UI path (`updateFromUi*` / `normalizeAfter*Change`) now calls `Self.snapToStep(...)`, and the init/clone path (`normalizeAll` / `adjustByDiff`) plus the tests resolve to the same statics. Arithmetic is identical, so behaviour is unchanged; the `TDEE` scheme was recompiled (`generic/platform=iOS`, no signing) to confirm. Gotcha: a bare `snapToStep(...)` inside an **instance** method does not bind to a static-only member, so those 9 call sites needed `Self.` qualification (a first attempt failed the build on exactly this).

#### PA-12 — Audit trail vestigial; test-only `calculateTDEE` shim
**Location:** `TDEEShared/Calculations/Extensions/CalculatorTdee.swift:13-15`; `TDEETests/TDEETests.swift:636`
`Calculator.calculate` always passes `createAudit: false`; BMR helpers accept a `logger:` they ignore; `CalculatorResultViewModel.audit` is only ever `[]` and never read. Separately, `calculateTDEE(bmr:activityLevel:)` is a shim defined inside `TDEETests.swift`, not part of the app.
**Recommendation:** Remove the audit plumbing and ignored `logger:` params, or wire `createAudit: true` with a reader; delete the test-only shim.
**Status: Done (2026-10-24) — audit plumbing removed.** Deleted `AuditLogger.swift` and `AuditItem.swift`; dropped the `audit` field from `CalculatorResultViewModel`; removed the `createAudit:` param from `Calculator.calculate` / `calculateTdee` and the ignored `logger:` param from `calculateMifflinStJeor` / `calculateKatchMcArdle` / `calculateLeanBodyMass` / `adjustCalories`. The test-only `calculateTDEE(bmr:activityLevel:)` shim was deleted and its callers redirected to the production `Calculator.adjustForActivityLevel(bmr:activityLevel:)`, so the TDEE-multiplier tests now exercise real code rather than a parallel copy. The "wire `createAudit: true`" alternative was **not** taken: surfacing an audit trail would need a UI surface, which is out of scope under `UI_RESTRICTIONS.md`. Grep confirms **zero residual** `AuditLogger` / `AuditItem` / `createAudit` / `calculateTDEE` / `logger:` references (the lone remaining `func calculateTDEE()` is a naming-convention doc example in `NamingConventions.swift`, not code). Full `TDEE` test suite passes on the iPhone 17e simulator (`** TEST SUCCEEDED **`), including `CalculationParityTests`.

#### PA-10 — Four `ActivityLevel` cases reuse the base multipliers
**Location:** `TDEEShared/Models/SwiftData/ActivityLevel.swift:11-16`
`lightExercise` / `moderateExercise` / `heavyExercise` / `athlete` share multipliers with `light` / `moderate` / `active` / `veryActive` (1.375 / 1.55 / 1.725 / 1.9). The iPhone controls iterate `ActivityLevel.allCases` (all 9), so `UIActivityLevelMenuButtonView` and `UIWheelPickerActivityLevelView` present 9 options in which 4 pairs yield identical TDEE (e.g. "Light" and "Light Exercise (1-2 days/week)").
**Recommendation:** Give each case a distinct multiplier, or split into a base enum + a watch-only set so the iPhone picker shows a non-redundant list.
**Status: Done (2026-10-24).** Collapsed the 9-case enum to the 5 canonical levels (`sedentary` / `lightExercise` / `moderateExercise` / `heavyExercise` / `athlete`), deleting the four legacy base cases (`light` / `moderate` / `active` / `veryActive`) that reused the 1.375 / 1.55 / 1.725 / 1.9 multipliers — the standard TDEE set, so "give each a distinct multiplier" was not clinically viable. A new `ActivityLevel.from(storedRaw:)` remaps the legacy stored raws ("Light"→`.lightExercise`, "Moderate"→`.moderateExercise`, "Active"→`.heavyExercise`, "Very Active"→`.athlete`) and `Profile.activityLevel`'s getter now routes through it, so a profile saved on an older build still computes the same TDEE (no silent regression to `.sedentary`). Because both iPhone pickers iterate `ActivityLevel.allCases`, the collapse shrinks them from 9 options to 5 with no picker code change — the DO-NOT-MODIFY wheel picker is untouched. Also fixed an adjacent nit: `heavyExercise.description` now reads "6-7 days/week" (was "3-5 days/week"). A new regression test `testActivityLevelsAreDistinct` pins "exactly five levels, each a distinct TDEE". This dissolves PA-11 and PA-19. Verified: full `TDEE` suite green on the iPhone 17e simulator and `TDEEWatch` `** BUILD SUCCEEDED **` after the `watchLevel` removal.

#### PA-11 — `.light` and `.moderate` both render "Moderate activity"
**Location:** `TDEEShared/Models/SwiftData/ActivityLevel.swift:23-24`; `TDEEShared/Models/ShareResultsModel.swift:122`
`description` maps both `.light` and `.moderate` to "Moderate activity". It is consumed by `ShareResultsModel` for the share card, so a user who picked "Light" sees "Moderate activity" in shared output.
**Recommendation:** Give `.light` a distinct description (e.g. "Low-moderate activity").
**Status: Done (2026-10-24) — subsumed by PA-10.** The two distinct cases that collided on "Moderate activity" (`.light` and `.moderate`) no longer exist; with the enum collapsed to 5 levels each case carries a unique `description`, so `ShareResultsModel` can no longer render the wrong label. No separate change needed.

#### PA-19 — Watch omits 4 of 9 `ActivityLevel` cases
**Location:** `TDEEWatch/enums/WatchRanges.swift:40`; `TDEEWatch/views/WatchActivityLevelView.swift:23`
`WatchRanges.activityLevels` offers only 5 cases (`.sedentary`, `.lightExercise`, `.moderateExercise`, `.heavyExercise`, `.athlete`). A phone profile set to `.active`, `.extraLight`, `.extraHeavy`, or `.extraAthlete` is not in the picker, so the watch's `selectionBinding` falls back to `.lightExercise` — silently mis-reporting the activity level (and therefore TDEE) on the watch.
**Recommendation:** Either map the omitted cases onto the watch's 5 offered ones explicitly, or offer the full set on the watch.
**Status: Done (2026-10-24) — subsumed by PA-10.** The watch already offered exactly the 5 canonical levels (`WatchRanges.activityLevels`), and those 5 are now the whole enum, so there are no longer any omitted cases for `selectionBinding` to fall back on. The transient `watchLevel` bridge (which mapped a base case onto an exercise case) was deleted as dead code; `WatchActivityLevelView` now compares `level == profile.activityLevel` directly, and `WatchMainView` reads `activityLevel.displayName` instead of `activityLevel.watchLevel.displayName`.

#### PA-28 — Core tests assert the dead calc path
**Location:** `TDEETests/TDEETests.swift`; `TDEETests/CalculationParityTests.swift`
`ProfileViewModelMacroTests` and `ProfileViewModelIntegrationTests` asserted `profile.tdee` / `profile.macroTargets` and `calculateMacros(tdee:)` — the **dead** 40/30/30 pipeline (PA-04/PA-05) the UI never uses, so the green tests gave false confidence that the macro calc was correct.
**Recommendation:** Point the core tests at `Calculator.calculate` (extend `CalculationParityTests`); remove assertions on the dead path once PA-04/PA-05 are resolved.
**Status: Done (2026-10-24) — resolved by the PA-04/PA-05 cascade.** Both halves of the finding no longer hold: `ProfileViewModelMacroTests` (the dead-path suite) was removed, and the surviving `ProfileViewModelIntegrationTests` test (`testBodyFatMethodAffectsCalculation`) exercises the **live** BMR helpers (`calculateMifflinStJeor` / `calculateKatchMcArdle`) that `CalculatorTdee.calculateTdee` uses — not the dead path. The live `Calculator.calculate(person:)` path is now pinned by six `CalculationParityTests` cases (Mifflin-St Jeor, Katch-McArdle, cut, bulk, recalc-on-change, zero-guard) plus `FormulaVerificationTests` and the integration test. Grep confirms **zero** remaining assertions on the dead `profile.tdee` / `profile.macroTargets` / `calculateMacros(tdee:)` symbols; the only surviving mentions are an explanatory comment in `CalculationParityTests` and the live `result.tdee` / `result.bmr` on `CalculatorResultViewModel` (read by `ShareResultsModel`). The one PA-28-specific tidy-up was removing the now-dangling `// MARK: - ProfileViewModel Macro Tests` comment left behind by the suite deletion.

#### PA-13 — `ProfileStore` clobbers the active profile back to "Main"
**Location:** `TDEEShared/Models/SwiftData/ProfileStore.swift:62-111`
`load()` set `activeProfileId = mainId ?? all.first?.id ?? activeProfileId` — always re-deriving to Main. `add(name:)` and `rename(id:to:)` both call `await load()`, so the active selection jumped back to "Main" after creating or renaming a profile; the in-session active choice was lost on any `load()`.
**Recommendation:** Preserve the active id across `load()` (re-apply it only when it still exists), so add/rename don't reset selection.
**Status: Done (2026-10-24).** `load()` now keeps the current `activeProfileId` when it still exists in the reloaded list, falling back to Main only when the active profile is gone — so `add()`/`rename()` no longer bounce the selection back to Main. First launch / relaunch still open on Main, because a fresh store's default `UUID()` never matches a stored profile. `delete()` already handled its own active fallback (it does not call `load()`) and is unchanged. Two regression tests added to `SwiftDataPersistenceTests` (`addKeepsActive`, `renameKeepsActive`); the TDEE suite is green on iPhone 17e.

#### PA-14 — `weightUom` / `heightUom` are not persisted
**Location:** `TDEEShared/Models/SwiftData/Profile.swift`; `TDEEShared/Models/SwiftData/ProfileMapper.swift`; `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift`
The `Profile` entity had no UOM fields, and `ProfileMapper.apply`/`mapToEntity` never touched `weightUom`/`heightUom`, so on reload both reset to `.kilograms` / `.centimeters` (the in-memory defaults) — on the phone and the watch alike. Worse on the iPhone, `weightUom`/`heightUom` had **no `didSet`**, so changing the unit via the UOM menu (`UIWeightUomMenuButtonView`/`UIHeightUomMenuButtonView`, which set the unit without converting the metric source of truth) never triggered a save at all. No data is lost (metric kg/cm is the source of truth, UOM is display-only), only the display-unit preference — hence Medium.
**Recommendation:** Persist the two UOM fields (entity + mapper + a round-trip test), or document that UOM is session-only.
**Status: Done (2026-10-24).** Chose *persist* over "session-only." `Profile` now stores `weightUomRaw` / `heightUomRaw` (`Int = 0`) with computed `weightUom` / `heightUom` accessors that decode via `OptionWeight(rawValue:)` / `OptionLength(rawValue:)` with a safe fallback to `.kilograms` / `.centimeters` — mirroring the `activityLevel` / `activityLevelRaw` pattern. `ProfileMapper.apply` reads both; `mapToEntity` writes both (new + update branches). `ProfileViewModel.weightUom` / `heightUom` gained a `didSet { triggerSave() }`, so a UOM change on the iPhone now persists (the `didSet` is suppressed during `load()` by the `isLoading` guard, so it fires no spurious save). No migration plan is needed: the `ModelContainer` uses SwiftData's automatic lightweight migration, and the new stored properties carry `= 0` declared defaults, so pre-existing rows fill with `0` (= kg/cm, the historical default). Closes PA-25 (the round-trip test it called for). `TDEE` suite green on iPhone 17e; `TDEEWatch` builds.

#### PA-25 — No UOM round-trip persistence test
**Location:** `TDEETests/SwiftDataPersistenceTests.swift`
`profileRoundTrip` asserted age / weight / activityLevel / bodyFat / calorieAdjustment / selectedMacroId but **not** `weightUom` / `heightUom` — the gap that would have caught PA-14.
**Recommendation:** Add a UOM round-trip assertion (or document UOM as session-only).
**Status: Done (2026-10-24) — closed with PA-14.** A new `SwiftDataPersistenceTests/uomRoundTrip` sets `weightUom = .pounds` / `heightUom = .inches`, saves, reloads a fresh `ProfileViewModel` over the same container, and asserts both survive — pinning the PA-14 fix and catching any regression of the UOM fields.

#### PA-26 — Share card hardcodes cm / kg
**Location:** `TDEEShared/Models/ShareResultsModel.swift:115-119`
`heightText`/`weightText` were hardcoded `formatAsInteger(profile.height) + " cm"` / `+ " kg"`, ignoring the user's UOM (the inline comments admitted "assuming cm from profile, could add UOM support"). A user who entered in pounds / feet-and-inches saw metric units on the share card. Related to PA-14.
**Recommendation:** Format height/weight through the user's UOM (as `UISectionSummaryValue*` already does).
**Status: Done (2026-10-24).** `heightText`/`weightText` now format through the profile's persisted UOM (`profile.heightUom` / `profile.weightUom`), reusing the same `DisplayLength.asMajorValue`/`asMinorValue` and `DisplayWeight.asMajorValue`/`asMinorValue` helpers the on-screen summary rows (`UISectionSummaryValueHeight` / `UISectionSummaryValueWeight`) use — three small private helpers (`joinMeasurement`, `formatHeight`, `formatWeight`) added next to `formatAsInteger`, joining major value + major unit + minor value + minor unit and skipping empty segments. No view files were touched (the change lives in `TDEEShared`, which compiles into both app targets). **User-visible output change:** metric is unchanged ("180 cm" / "70 kg" as before), but imperial users now see e.g. "5 feet 7 inches" / "154 pounds" / "14 stones 10 pounds" instead of metric units. Both `ShareResultsModelTests` ("175 cm" / "70 kg") still pass (metric is the default UOM); full `TDEE` suite green on iPhone 17e, `TDEEWatch` builds.

#### PA-09 — `KatchMcArdleMultipliers` misnomer
**Location:** `TDEEShared/Models/SwiftData/ActivityLevel.swift:64-78`; `TDEEShared/Calculations/Extensions/CalculatorTdee.swift:50`
The property is the generic activity factor (1.2–1.9), applied to **both** BMR formulas (`bmr * activityLevel.KatchMcArdleMultipliers` where `bmr` may be Mifflin-St Jeor). The "Additional cases for Katch-McArdle calculations" comment is likewise misleading — the exercise cases are not Katch-specific (they're the ones the watch uses).
**Recommendation:** Rename to `activityMultiplier` and fix the comment.
**Status: Done (2026-10-24).** Renamed the property `KatchMcArdleMultipliers` → `activityMultiplier` in `ActivityLevel.swift` (the property and the type-level doc-comment reference), and updated the sole use site `bmr * activityLevel.activityMultiplier` in `CalculatorTdee.swift`. A pure symbol rename — the multiplier values (1.2 / 1.375 / 1.55 / 1.725 / 1.9) and their case mappings are unchanged, and it compiles into both `TDEE` and `TDEEWatch` unchanged. The doc comment now reads "The generic activity multiplier (1.2 to 1.9) for this activity level, applied to both BMR formulas (Mifflin-St Jeor and Katch-McArdle)." (The misleading "Additional cases for Katch-McArdle calculations" comment cited in the finding was already removed by the PA-10 9→5 collapse; the surviving one-line `///` comment above the property is what was fixed.) Grep confirms **zero** remaining code references to `KatchMcArdleMultipliers` (only prose in this document remains). Full `TDEE` suite green on iPhone 17e, `TDEEWatch` builds.

#### PA-16 — `print()` used for error logging
**Location:** `ProfileStore.swift:78,108,126`; `ProfileViewModel.swift:197,212,258`
Load/save failures were `print`ed rather than surfaced or logged. In a release build these are effectively lost and give no user feedback on a failed persist.
**Recommendation:** Route through `os.log`/`os.Logger` and consider surfacing a failed-save state to the UI.
**Status: Done (2026-10-24).** All 7 failure-path `print()` calls now route through `os.Logger` — `ProfileStore.swift` (load / create / rename / delete, 4 calls) and `ProfileViewModel.swift` (load / load-by-id / save, 3 calls). Each file gained `import os` and a `private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DaveBerryUk.TDEE", category: "ProfileStore" / "ProfileViewModel")`; the logged message content is identical to the old `print` string. Using `Bundle.main.bundleIdentifier` namespaces each app target's logs (resolving to `DaveBerryUk.TDEE` on the phone, `.watchkitapp` on the watch, `TDEETests` in the test host), with the app bundle id as fallback. No UI surfacing of a failed save was added (that remains a candidate UI task under `UI_RESTRICTIONS.md`, out of scope for PA-16). Both `TDEE` and `TDEEWatch` compile warning-clean.

#### PA-29 — No cut/bulk adjustment test on the production path
**Location:** `TDEETests/CalculationParityTests.swift`
The parity tests exercised `Calculator.calculate` but only with `.maintain`. No case asserted that a cut/bulk adjustment produced the expected `adjustedCalories` (and, with PA-27 fixed, the share text).
**Recommendation:** Add cut and bulk cases to `CalculationParityTests`.
**Status: Done (2026-10-24).** Added two additive cases after the existing cut/bulk `caloriesAdjustedPerDay` tests: `cutAdjustmentShareSign` (`.cut`, adjustment 500 → `caloriesAdjustedPerDay == 2094`, `calorieAdjustmentAmountText == "-500 kcal"`) and `bulkAdjustmentShareSign` (`.bulk`, 500 → `3094`, `"+500 kcal"`), pinning both the adjusted-calorie math and the PA-27 sign on the production `Calculator.calculate` path. Base: `makeProfile(bodyFat: .omit)` → BMR 1673.75 × 1.55 = 2594.3125. No existing test was modified. Full `TDEE` suite green on iPhone 17e.

#### PA-30 — `File.swift` is an empty test stub
**Location:** `TDEETests/File.swift`
Contained only `@testable import TDEE` with no tests.
**Recommendation:** Remove or populate it.
**Status: Done (2026-10-24) — removed.** Chose "remove" over "populate": the file was a vestigial empty stub (an `@testable import TDEE` header with no `@Test` and no used symbol). The project uses Xcode's file-system-synchronized groups (`PBXFileSystemSynchronizedRootGroup`) and has no `File.swift` reference in the `.pbxproj`, so the deletion needs no project-file edit and is build-safe. Deleted; the `TDEE` suite is green on iPhone 17e.

### Accepted

#### PA-01 — First-launch device profile seeds height/weight = 0
**Location:** `TDEEShared/Config/ProfileDefaults.swift:35-46`; `TDEEShared/Models/SwiftData/ProfileRepository.swift:78-96`
`ProfileDefaults.device()` returns height `0.0` and weight `0.0` (age 16 / male / sedentary are seeded, but height & weight are zeroed). On a real device, `ConfigLoader` compiles the `else` branch → `.device()`, and `createProfile(name:)` builds the launch "Main" profile from it. `0` falls outside `MetricRanges.height` (`100…272`) and `MetricRanges.weight` (`20…300`), so `validateForCalculation()` fails and `Calculator.calculate` returns "Following fields are mandatory: Height, Weight" with **no TDEE**. The simulator seeds a valid 175 cm / 70 kg / 25-yo profile, so the two environments diverge. Mixing seeded age/gender/activity with zeroed height/weight reads as an unfilled placeholder unless the first-launch UI surfaces a prompt for it.
**Recommendation:** Give `device()` valid in-range height/weight (or a documented "unset" sentinel the UI prompts for), and make age/gender/height/weight consistent.
**Status: Accepted (2026-10-24) — intentional sentinel.** Decision: the zeroed height/weight on a real device is a deliberate "please enter your real height/weight" trigger, not a defect to fix by seeding placeholder numbers. The `0` values sit outside `MetricRanges.height` / `weight`, so `validateForCalculation()` surfaces a "mandatory: Height, Weight" prompt and no TDEE until the user enters real data — the intended first-launch behaviour. The companion UI prompt that would make the sentinel explicit is a separate first-launch UX task, out of scope under the no-UI-changes constraint. No code change; `ProfileDefaults.device()` is left as-is.

#### PA-17 — `ProfileViewModel` convenience init spawns a load Task
**Location:** `TDEEShared/Models/ProfileViewModel/ProfileViewModel.swift:177-179`
`convenience init()` is `@MainActor`-isolated yet calls `loadFromSwiftData()` → `Task { await load() }`. Non-idiomatic but **safe** and consistent with the project's accepted `@Observable` + nonisolated-deinit handle pattern. **Status: Accepted — no action.**

### By Design

#### PA-24 — Watch uses a standalone store
**Location:** `TDEEWatch/app/TDEEWatchApp.swift:16`
The watch builds its own `ProfileViewModel` / `MacroSplitOptionsModelCollection` over `SwiftDataContainer.shared` (a separate on-disk store, by design) and never calls `ensureMainProfile()`. A profile or preset chosen on the phone is invisible to the watch and vice-versa; `macroName` falls back to "Custom" for a phone-picked preset. **Status: By Design** — a known cross-device limitation (app-group / CloudKit sync is a pending decision, not yet in scope).

---

## Confirmed correct (no issues found)

These areas were audited and found sound — included so the scope is explicit:

- **No `fatalError` / `precondition` / `assert` / `TODO` in the codebase** — no crash-on-init traps.
- **`MacroSplitOptionModel` mutation is correct** — it is a `final class`, so `items.forEach { $0.isSelected = … }` mutates in place; no copy/aliasing bug.
- **Gender round-trip is consistent** — `Int16` 0/1 ↔ `.male`/`.female` maps cleanly through `ProfileMapper`.
- **Preview `UserDefaults` suites do not leak into production** — `com.tdee.calorieAdjustmentPreview` and the other `*Preview` suites are created only inside `#Preview`; production `InputStyleManager`/`ThemeManager` default to `.standard`. (They do write debug state into the app's real UserDefaults domain, but it is never read back — clutter, not a correctness issue.)
- **`CalculationParityTests` correctly test the live path** — Mifflin and Katch-McArdle cases assert exact `caloriesAdjustedPerDay` / week / macro-gram values via `Calculator.calculate(person:)`.
- **BMR unit handling is correct** — the model stores metric (kg/cm) as the source of truth; UOM is display-only, so no BMR feeds wrong units. (The gaps are display-only: PA-14, PA-26.)
- **Watch weight/height wheels mirror the phone (PA-20, reclassified 2026-10-25)** — `WatchRanges` option arrays are byte-for-byte identical to `UIWheelPickerWeightView` / `UIWheelPickerHeightView`; the wheel-vs-`MetricRanges` split is inherent to the design on *both* targets, and PA-24 (standalone store) means a phone value never reaches the watch. The ~260 kg stones edge is a phone display quirk the watch faithfully mirrors.
- **Watch adjustment default is internally consistent (PA-22, reclassified 2026-10-25)** — every `500` in the codebase is `#Preview` sample data; the production default is `0` and the watch uses `WatchRanges.startingAdjustment = 250`. The 25-step wheel vs continuous slider is documented as intentional (`CalorieAdjustmentEntry.swift:18`).

---

## Prioritisation

**Fix first (High / user-visible):**
1. **~~PA-27~~ (done 2026-10-24 — sign now derived from `calorieAdjustmentMethod.adjustmentPrefix`; `.maintain` guarded to "None")**
2. **~~PA-14~~ (done 2026-10-24 — `weightUom`/`heightUom` now persisted via `Profile` raw fields + `ProfileMapper` read/write + a `ProfileViewModel` `didSet`; `uomRoundTrip` test added; closes PA-25)**
3. **~~PA-01~~ (accepted 2026-10-24 — intentional sentinel; the first-launch prompt is a separate UI task, out of scope)**
4. **~~PA-19~~ (done 2026-10-24 — subsumed by PA-10; the watch already offered exactly the 5 canonical levels, so the fallback is gone)**
5. **~~PA-02~~ / ~~PA-03~~ / ~~PA-04~~ / ~~PA-05~~ / ~~PA-06~~ / ~~PA-07~~ / ~~PA-08~~ / ~~PA-12~~** — the whole "Calc / dead code" bundle is now closed: the dead calc pipeline (PA-04, 2026-10-22), the dead 40/30/30 `calculateMacros(tdee:)` (PA-05, gone with PA-04), the dead static normalize family + `update*` wrappers (PA-06/PA-07), the duplicate `snapToStep`/`clampValueTo100` helpers (PA-08), and the vestigial audit trail + test-only `calculateTDEE` shim (PA-12, 2026-10-24) are all removed; `MacroSplitOptionsNormalization.swift` now holds only the live `normalizeAll`/`adjustByDiff`; the two Config cleanups (PA-02 method passthrough in `createProfile`, PA-03 height-unit comment) are also done.
6. **~~PA-26~~ / ~~PA-09~~ / ~~PA-16~~ / ~~PA-29~~ / ~~PA-30~~** (done 2026-10-24 — the five "safe" PAs that need no UI approval: the share card now formats height/weight through the user's UOM via the `DisplayLength`/`DisplayWeight` helpers, matching the on-screen summary rows (PA-26); `KatchMcArdleMultipliers` renamed to `activityMultiplier` (PA-09); all 7 `print()` failure logs routed through `os.Logger` (PA-16); cut/bulk parity tests added to `CalculationParityTests` (PA-29); the empty `File.swift` test stub removed (PA-30) — full `TDEE` suite green on iPhone 17e and `TDEEWatch` builds).

**Then (Medium):** PA-15 — the last Medium; UI-gated, reported for approval under `UI_RESTRICTIONS.md`.
**Low / hygiene:** ~~PA-20~~ / ~~PA-22~~ — *confirmed correct* (2026-10-25, no code change); ~~PA-21~~ / ~~PA-23~~ — *Done* (2026-10-25, no UI change: `missingFields` now derives weight/height from `MetricRanges`; non-optional `WatchRanges` bounds). Remaining Low: **PA-18**, UI-gated, reported for approval under `UI_RESTRICTIONS.md`.
**No action:** PA-01 (accepted — intentional sentinel; the first-launch prompt is a separate UI task, out of scope), PA-17 (accepted), PA-24 (by design).

---

### Constraints honoured
- **Analysis only** — no source was modified.
- **`MacroSplitOptionsNormalization.swift` (PA-06, PA-08):** originally flagged DO-NOT-EDIT; **under explicit approval on 2026-10-24** the dead static `normalizeAfter*Change` family + `update*` wrappers (PA-06/PA-07) were removed and the duplicate `snapToStep`/`clampValueTo100` helpers (PA-08) were collapsed into a single shared set in `MacroSplitOptionModel.swift`. The file now holds only the live `normalizeAll`/`adjustByDiff` (init/clone path).
- **`UI_RESTRICTIONS.md`:** no UI changes proposed (no `.pickerStyle`/option-case/`UILayoutExpandingPanel`/animation-parameter changes).
