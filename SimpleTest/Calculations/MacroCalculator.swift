//
//  MacroCalculator.swift
//  SimpleTest
//
//  Created by David Berry on 19/04/2026.
//

struct MacroCalculator {
    
    static func calculate(person: ProfileViewModel, tdee: TdeeResultViewModel) -> MacroSplitResultViewModel {
        
        let calories : Int = Int(tdee.bmr)
        
        var adjustment : Int = 0;
        switch person.calorieAdjustmentMethod {
            
        case .cut:
            adjustment = Int(-person.calorieAdjustment)
            break
            
        case .bulk:
            adjustment = Int(person.calorieAdjustment)
            break
            
            default :
            break
        }
        
        let caloriesAdjustedPerDay : Int =  calories + adjustment
        let caloriesAdjustedPerWeek : Int = caloriesAdjustedPerDay * 7
        
        let proteinPercent: Int = 40
        let carbsPercent: Int = 40
        let fatsPercent: Int = 20 // Adjusted to ensure total is 100%
        
        let proteinGrams = Int(Double(proteinPercent) * Double(caloriesAdjustedPerDay) / 100 / 4)
        let carbsGrams = Int(Double(carbsPercent) * Double(caloriesAdjustedPerDay) / 100 / 4)
        let fatsGrams = Int(Double(fatsPercent) * Double(caloriesAdjustedPerDay) / 100 / 9)
        
        return MacroSplitResultViewModel(
            proteinPercent: proteinPercent,
            carbsPercent: carbsPercent,
            fatsPercent: fatsPercent,
            proteinGrams: proteinGrams,
            carbsGrams: carbsGrams,
            fatsGrams: fatsGrams,
            calories: calories,
            caloriesAdjustedPerDay: caloriesAdjustedPerDay,
            caloriesAdjustedPerWeek: caloriesAdjustedPerWeek
        )
    }
    
}
