//
//  Untitled.swift
//  SimpleTest
//
//  Created by David Berry on 06/04/2026.
//

import Foundation

struct Calculator {
    
    static func calculate(person: ProfileViewModel, createAudit: Bool = false) -> CalculatorResultViewModel {

        let result = CalculatorResultViewModel()
        
        if let errors = person.validateForCalculation() {
            result.updateErrorMessage(message: errors)
            return result
        }
        
        Calculator.calculateTdee(result: result, person: person, createAudit: createAudit)
        person.calculateMacros(result: result )
        return result
        
    }

}
