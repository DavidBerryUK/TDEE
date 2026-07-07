//
//  ProfileViewModelMacro.swift
//  SimpleTest
//
//  Created by David Berry on 15/04/2026.
//

extension ProfileViewModel {

    /// Copy protein/carbs/fats from a macro preset option into this profile.
    /// Call before calculating so the computation uses the user's actual selection.
    func syncMacros(from macroOption: MacroSplitOptionsModel) {
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
    
    private var overflow: Int {
        100 - (protein + carbs + fats)
    }
    
    internal func normalizeAll() {
        protein = clampValueTo100(protein)
        carbs = clampValueTo100( carbs + overflow )
        fats = clampValueTo100( fats + overflow )
    }
    
    private func normalizeAfterProteinChange(newValue: Double) {
        protein = snapToStep(newValue)
        carbs = clampValueTo100( carbs + overflow )
        fats = clampValueTo100( fats + overflow )
    }
    
    private func normalizeAfterCarbsChange(newValue: Double) {
        carbs = snapToStep(newValue)
        fats = clampValueTo100( fats + overflow )
        protein = clampValueTo100( protein + overflow )
    }
    
    private func normalizeAfterFatsChange(newValue: Double) {
        fats = snapToStep(newValue)
        carbs = clampValueTo100( carbs + overflow )
        protein = clampValueTo100( protein + overflow )
    }
    
}
