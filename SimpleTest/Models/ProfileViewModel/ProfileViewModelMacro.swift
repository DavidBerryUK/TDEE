//
//  ProfileViewModelMacro.swift
//  SimpleTest
//
//  Created by David Berry on 15/04/2026.
//

extension ProfileViewModel {

    /// Copy protein/carbs/fats from a macro preset option into this profile.
    /// Call before calculating so the computation uses the user's actual selection.
    func syncMacros(from macroOption: MacroSplitOptionModel) {
        protein = macroOption.protein
        carbs   = macroOption.carbs
        fats    = macroOption.fats
    }

    func updateProtein(to newValue: Double) {
        normalizeAfterProteinChange(newValue: newValue)
    }

    func updateCarbs(to newValue: Double) {
        normalizeAfterCarbsChange(newValue: newValue)
    }

    func updateFats(to newValue: Double) {
        normalizeAfterFatsChange(newValue: newValue)
    }

    private func snapToStep(_ value: Double, step: Int = 5, min: Int = 0, max: Int = 100) -> Int {
        let snapped = Int(value / Double(step)) * step
        return Swift.max(min, Swift.min(max, snapped))
    }

    private func clampValueTo100(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }

    internal func normalizeAll() {
        // Snapshot before any mutation so overflow is computed from the original total.
        let snapshotProtein = protein
        let snapshotCarbs   = carbs
        let snapshotFats    = fats
        let overflow        = 100 - (snapshotProtein + snapshotCarbs + snapshotFats)

        protein = clampValueTo100(snapshotProtein + overflow)
        carbs   = clampValueTo100(snapshotCarbs   + overflow)
        fats    = clampValueTo100(snapshotFats    + overflow)
    }

    private func normalizeAfterProteinChange(newValue: Double) {
        // Snapshot so overflow reflects the change from old protein to new, not a fresh read.
        let snapshotCarbs  = carbs
        let snapshotFats   = fats
        let overflow       = 100 - (Int(newValue) + snapshotCarbs + snapshotFats)

        protein = snapToStep(newValue)
        carbs   = clampValueTo100(snapshotCarbs + overflow)
        fats    = clampValueTo100(snapshotFats  + overflow)
    }

    private func normalizeAfterCarbsChange(newValue: Double) {
        // Snapshot so overflow reflects the change from old carbs to new, not a fresh read.
        let snapshotProtein = protein
        let snapshotFats    = fats
        let overflow        = 100 - (snapshotProtein + Int(newValue) + snapshotFats)

        carbs   = snapToStep(newValue)
        fats    = clampValueTo100(snapshotFats  + overflow)
        protein = clampValueTo100(snapshotProtein + overflow)
    }

    private func normalizeAfterFatsChange(newValue: Double) {
        // Snapshot so overflow reflects the change from old fats to new, not a fresh read.
        let snapshotProtein = protein
        let snapshotCarbs   = carbs
        let overflow        = 100 - (snapshotProtein + snapshotCarbs + Int(newValue))

        fats    = snapToStep(newValue)
        carbs   = clampValueTo100(snapshotCarbs + overflow)
        protein = clampValueTo100(snapshotProtein + overflow)
    }

}
