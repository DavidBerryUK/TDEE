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
        let result = MacroSplitOptionModel.normalizeAfterProteinChange(newValue: newValue, originalCarbs: self.carbs, originalFats: self.fats)
        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

    func updateCarbs(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterCarbsChange(newValue: newValue, originalProtein: self.protein, originalFats: self.fats)
        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

    func updateFats(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterFatsChange(newValue: newValue, originalProtein: self.protein, originalCarbs: self.carbs)
        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

}
