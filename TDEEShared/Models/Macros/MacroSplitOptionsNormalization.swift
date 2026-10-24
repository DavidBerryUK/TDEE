//
//  MacroSplitOptionsNormalization.swift
//  TDEE
//
//  Created by David Berry on 12/09/2026.
//

import Foundation

/// Shared normalization helpers for macro split options (protein/carbs/fats).
///
/// All values are clamped to [0, 100] and overflow is distributed so that
/// the total is exactly 100, with all values snapped to the step (5%).
///
/// The normalization algorithm:
/// 1. Clamp each value to [0, 100]
/// 2. Snap each value to step (5%)
/// 3. If sum != 100, adjust the largest value to compensate

// Static normalization helpers — defined in an extension on MacroSplitOptionModel.
// Callers reference the type (MacroSplitOptionModel) rather than the filename.

extension MacroSplitOptionModel {
    static func normalizeAll(protein: Int, carbs: Int, fats: Int) -> (protein: Int, carbs: Int, fats: Int) {
        var protein = clampValueTo100(protein)
        var carbs = clampValueTo100(carbs)
        var fats = clampValueTo100(fats)

        // Snap each to step
        protein = snapToStep(Double(protein))
        carbs = snapToStep(Double(carbs))
        fats = snapToStep(Double(fats))

        let sum = protein + carbs + fats

        guard sum != 100 else {
            return (protein, carbs, fats)
        }

        let diff = 100 - sum

        // Find the largest value and adjust it by diff (staying within bounds and step)
        let (newProtein, newCarbs, newFats) = adjustByDiff(&protein, &carbs, &fats, diff: diff)

        return (newProtein, newCarbs, newFats)
    }

    private static func adjustByDiff(_ protein: inout Int, _ carbs: inout Int, _ fats: inout Int, diff: Int) -> (protein: Int, carbs: Int, fats: Int) {
        guard diff != 0 else {
            return (protein, carbs, fats)
        }

        let step = MacroSplitOptionModel.stepSize

        // Determine which field has the most room to change in the direction of diff
        var fieldIndex = 0  // 0 = protein, 1 = carbs, 2 = fats
        var maxChange = 0

        if diff > 0 {
            // Need to increase - find field with most room to increase
            let proteinRoom = 100 - protein
            let carbsRoom = 100 - carbs
            let fatsRoom = 100 - fats

            if proteinRoom >= step && proteinRoom >= carbsRoom && proteinRoom >= fatsRoom {
                maxChange = (proteinRoom / step) * step
                fieldIndex = 0
            } else if carbsRoom >= step && carbsRoom >= proteinRoom && carbsRoom >= fatsRoom {
                maxChange = (carbsRoom / step) * step
                fieldIndex = 1
            } else if fatsRoom >= step {
                maxChange = (fatsRoom / step) * step
                fieldIndex = 2
            }
        } else {
            // Need to decrease - find field with most room to decrease
            let proteinRoom = protein
            let carbsRoom = carbs
            let fatsRoom = fats

            if proteinRoom >= step && proteinRoom >= carbsRoom && proteinRoom >= fatsRoom {
                maxChange = (proteinRoom / step) * step
                fieldIndex = 0
            } else if carbsRoom >= step && carbsRoom >= proteinRoom && carbsRoom >= fatsRoom {
                maxChange = (carbsRoom / step) * step
                fieldIndex = 1
            } else if fatsRoom >= step {
                maxChange = (fatsRoom / step) * step
                fieldIndex = 2
            }
        }

        // Adjust by the minimum of diff and maxChange
        let actualAdjust = min(abs(diff), maxChange) * (diff > 0 ? 1 : -1)

        switch fieldIndex {
        case 0:
            protein = snapToStep(Double(protein) + Double(actualAdjust))
        case 1:
            carbs = snapToStep(Double(carbs) + Double(actualAdjust))
        case 2:
            fats = snapToStep(Double(fats) + Double(actualAdjust))
        default:
            break
        }

        // If still not 100 and we can adjust a different field, do so
        let newSum = protein + carbs + fats
        let remainingDiff = 100 - newSum

        if remainingDiff != 0 {
            // Find another field that can absorb the remaining diff
            for i in 0..<3 {
                if i == fieldIndex { continue }

                var currentVal = i == 0 ? protein : (i == 1 ? carbs : fats)
                let room = diff > 0 ? (100 - currentVal) : currentVal
                let maxAdjust = (room / step) * step
                let actualAdjust = min(abs(remainingDiff), maxAdjust) * (remainingDiff > 0 ? 1 : -1)

                if actualAdjust != 0 {
                    currentVal = snapToStep(Double(currentVal) + Double(actualAdjust))
                    if i == 0 { protein = currentVal } else if i == 1 { carbs = currentVal } else { fats = currentVal }
                    break
                }
            }
        }

        return (protein, carbs, fats)
    }
}
