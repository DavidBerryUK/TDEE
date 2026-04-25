//
//  MacroCalculator.swift
//  SimpleTest
//
//  Created by David Berry on 19/04/2026.
//

struct MacroCalculatorResult {
    let proteinGrams : Int
    let carbsGrams : Int
    let fatsGrams : Int
}


struct MacroCalculator {
    
    
    static func calculate(person: ProfileViewModel, tdee: TdeeResultViewModel ) -> MacroCalculatorResult {
        
        let calories = tdee.bmr
        
        let proteinPercent : Int = 40;
        let carbsPercent : Int = 40;
        let fatsPercent : Int = 40;
        
        let proteinGrams = Int( Double(proteinPercent) * calories / 100 / 4)
        let carbsGrams = Int( Double(carbsPercent) * calories / 100 / 4 )
        let fatsGrams = Int( Double(fatsPercent) * calories / 100 / 9 )
        
        return MacroCalculatorResult (
            proteinGrams: proteinGrams,
            carbsGrams: carbsGrams,
            fatsGrams: fatsGrams
        )
        
    }
    
}
