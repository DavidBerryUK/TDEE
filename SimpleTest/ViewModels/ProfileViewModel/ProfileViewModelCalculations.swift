//
//  ProfileViewModelCalculations.swift
//  SimpleTest
//
//  Created by David Berry on 15/04/2026.
//

extension ProfileViewModel {
        
    // get the result of tde calculations
    var tdeeResult: TdeeResult {
        TdeeCalculator.calculate(person: self)
    }
    
}
