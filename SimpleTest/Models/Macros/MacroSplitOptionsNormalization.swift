//
//  MacroSplitOptionsNormalization.swift
//  SimpleTest
//
//  Created by David Berry on 12/09/2026.
//

import Foundation

/// Shared normalization helpers for macro split options (protein/carbs/fats).
///
/// All values are clamped to [0, 100] and overflow from the third field is
/// distributed proportionally so that the total target of 100 is approximated.
///
/// - Warning: `step` in `snapToStep` must be a divisor of 100 (currently 5).
///   Changing this without updating callers can produce totals != 100.

// Static normalization helpers — defined in an extension on MacroSplitOptionModel.
// Callers reference the type (MacroSplitOptionModel) rather than the filename.

extension MacroSplitOptionModel {
    static func normalizeAll(protein: Int, carbs: Int, fats: Int) -> (protein: Int, carbs: Int, fats: Int) {
        let snapshotProtein = protein
        let snapshotCarbs   = carbs
        let snapshotFats    = fats
        let overflow        = 100 - (snapshotProtein + snapshotCarbs + snapshotFats)
        return (
            clampValueTo100(snapshotProtein + overflow),
            clampValueTo100(snapshotCarbs   + overflow),
            clampValueTo100(snapshotFats    + overflow)
        )
    }

    static func normalizeAfterProteinChange(newValue: Double, originalCarbs: Int, originalFats: Int) -> (protein: Int, carbs: Int, fats: Int) {
        let snapshotCarbs  = originalCarbs
        let snapshotFats   = originalFats
        let overflow       = 100 - (Int(newValue) + snapshotCarbs + snapshotFats)
        return (
            snapToStep(newValue),
            clampValueTo100(snapshotCarbs + overflow),
            clampValueTo100(snapshotFats  + overflow)
        )
    }

    static func normalizeAfterCarbsChange(newValue: Double, originalProtein: Int, originalFats: Int) -> (protein: Int, carbs: Int, fats: Int) {
        let snapshotProtein = originalProtein
        let snapshotFats    = originalFats
        let overflow        = 100 - (snapshotProtein + Int(newValue) + snapshotFats)
        return (
            clampValueTo100(snapshotProtein + overflow),
            snapToStep(newValue),
            clampValueTo100(snapshotFats  + overflow)
        )
    }

    static func normalizeAfterFatsChange(newValue: Double, originalProtein: Int, originalCarbs: Int) -> (protein: Int, carbs: Int, fats: Int) {
        let snapshotProtein = originalProtein
        let snapshotCarbs   = originalCarbs
        let overflow        = 100 - (snapshotProtein + snapshotCarbs + Int(newValue))
        return (
            clampValueTo100(snapshotProtein + overflow),
            clampValueTo100(snapshotCarbs + overflow),
            snapToStep(newValue)
        )
    }

    private static func snapToStep(_ value: Double, step: Int = 5, min: Int = 0, max: Int = 100) -> Int {
        let snapped = Int(value / Double(step)) * step
        return Swift.max(min, Swift.min(max, snapped))
    }

    private static func clampValueTo100(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }
}
