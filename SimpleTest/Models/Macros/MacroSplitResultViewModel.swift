//
//  MacroSplitResultViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 26/04/2026.
//
import Foundation
import Combine
import Observation

@Observable
final class MacroSplitResultViewModel : ObservableObject {
    let proteinPercent: Int
    let carbsPercent: Int
    let fatsPercent: Int
    
    let proteinGrams : Int
    let carbsGrams : Int
    let fatsGrams : Int
    
    
    init(
        proteinPercent: Int = 0,
        carbsPercent: Int = 0,
        fatsPercent: Int = 0,
        proteinGrams: Int = 0,
        carbsGrams: Int = 0,
        fatsGrams: Int = 0) {
            self.proteinPercent = proteinPercent
            self.carbsPercent = carbsPercent
            self.fatsPercent = fatsPercent
            self.proteinGrams = proteinGrams
            self.carbsGrams = carbsGrams
            self.fatsGrams = fatsGrams
        }
}
