//
//  InputStyleManagerTests.swift
//  TDEETests
//
//  Story 023 (Input Method) — round-trip and shape tests for the per-input Classic/New
//  preference store. Mirrors ThemeTests: each test uses an isolated UserDefaults suite, and a
//  fresh manager over the same suite simulates a relaunch.
//

import Testing
@testable import TDEE
import Foundation

@Suite("InputStyleManager Tests")
@MainActor
struct InputStyleManagerTests {

    /// A fresh, isolated defaults store per test.
    private func makeDefaults() -> UserDefaults {
        let name = "InputStyleManagerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    // MARK: - Defaults

    @Test("Defaults to Classic for every input when nothing is stored")
    func defaultsToClassic() {
        let manager = InputStyleManager(defaults: makeDefaults())

        for input in InputID.allCases {
            #expect(manager.style(for: input) == .classic, "expected .classic for \(input)")
        }
        #expect(manager.styles.isEmpty)
    }

    // MARK: - Set / read

    @Test("Setting an input to New updates it in place")
    func setStyleUpdatesInPlace() {
        let manager = InputStyleManager(defaults: makeDefaults())

        manager.setStyle(.new, for: .gender)

        #expect(manager.style(for: .gender) == .new)
    }

    @Test("Re-setting an input overwrites the previous style")
    func setStyleOverwrites() throws {
        let defaults = makeDefaults()
        let manager = InputStyleManager(defaults: defaults)

        manager.setStyle(.new, for: .gender)
        manager.setStyle(.classic, for: .gender)

        #expect(manager.style(for: .gender) == .classic)
        // Only one entry survives for the input, not one per call.
        let raw = try #require(defaults.dictionary(forKey: InputStyleManager.Keys.styles))
        #expect(raw.count == 1)
    }

    // MARK: - Persistence

    @Test("A New style persists across instances; unchosen inputs stay Classic")
    func newStylePersists() throws {
        let defaults = makeDefaults()
        let manager = InputStyleManager(defaults: defaults)

        manager.setStyle(.new, for: .gender)
        manager.setStyle(.new, for: .macroMix)

        // A fresh manager over the same store (a relaunch) sees the choice.
        let reloaded = InputStyleManager(defaults: defaults)
        #expect(reloaded.style(for: .gender) == .new)
        #expect(reloaded.style(for: .macroMix) == .new)
        // Inputs that were never set fall back to Classic.
        #expect(reloaded.style(for: .age) == .classic)
        #expect(reloaded.style(for: .weight) == .classic)
    }

    @Test("Persisted preferences use string keys and values")
    func persistedPlistIsStringKeyed() throws {
        let defaults = makeDefaults()
        let manager = InputStyleManager(defaults: defaults)

        manager.setStyle(.new, for: .gender)
        manager.setStyle(.classic, for: .weight)

        let raw = try #require(defaults.dictionary(forKey: InputStyleManager.Keys.styles))
        // Regression guard: an earlier version stored `InputID` enum keys, which UserDefaults
        // rejects with an NSException ("Attempt to insert non-property list object"). Both the
        // key and the value must be String.
        #expect(raw.count == 2)
        #expect(raw.allSatisfy { $0.key is String && $0.value is String })
        #expect(raw["gender"] as? String == "new")
        #expect(raw["weight"] as? String == "classic")
    }

    @Test("resetToClassic clears every stored preference")
    func resetClearsStore() {
        let defaults = makeDefaults()
        let manager = InputStyleManager(defaults: defaults)

        manager.setStyle(.new, for: .gender)
        manager.setStyle(.new, for: .macroMix)
        #expect(manager.style(for: .gender) == .new)

        manager.resetToClassic()
        #expect(manager.style(for: .gender) == .classic)
        #expect(manager.style(for: .macroMix) == .classic)

        // And the clearing survives a relaunch.
        let reloaded = InputStyleManager(defaults: defaults)
        #expect(reloaded.style(for: .gender) == .classic)
        #expect(reloaded.style(for: .macroMix) == .classic)
    }

    @Test("Invalid stored preferences are ignored and fall back to Classic")
    func invalidStoredValuesFallBackToClassic() {
        let defaults = makeDefaults()
        defaults.set([
            "gender": "banana",      // valid input, unknown style → skipped
            "not_an_input": "new",   // unknown input → skipped
            "age": "classic",        // both valid → kept
        ], forKey: InputStyleManager.Keys.styles)

        let manager = InputStyleManager(defaults: defaults)
        #expect(manager.style(for: .gender) == .classic)  // invalid style skipped
        #expect(manager.style(for: .age) == .classic)      // kept (was Classic)
        #expect(manager.style(for: .weight) == .classic)   // never stored
    }

    // MARK: - Sections (the view groups inputs by these)

    @Test("The five input sections carry their display titles")
    func sectionTitles() {
        #expect(InputSection.personal.title == "Personal")
        #expect(InputSection.activity.title == "Activity")
        #expect(InputSection.bodyFat.title == "Body Fat")
        #expect(InputSection.calories.title == "Calories")
        #expect(InputSection.macros.title == "Macros")
    }

    @Test("Sections partition every input")
    func sectionsPartitionInputs() {
        // Mirrors the view's `sections`: group all inputs by their section.
        let grouped = InputSection.allCases.map { section in
            InputID.allCases.filter { $0.section == section }
        }
        let all = grouped.flatMap { $0 }

        #expect(all.count == InputID.allCases.count)   // no input duplicated
        #expect(Set(all) == Set(InputID.allCases))      // no input dropped
    }
}
