//
//  Calculator.swift
//  TDEE
//
//  Created by David Berry on 06/04/2026.
//

import Foundation
import SwiftUI

/// Performs TDEE and macro calculations based on user profile data.
///
/// This struct serves as the entry point for all calculation operations,
/// coordinating BMR, TDEE, and macro calculations.
///
/// ## Usage
/// ```swift
/// let calculator = Calculator.calculate(person: profile)
/// ```
@MainActor
struct Calculator {

    /// Calculates TDEE and macro targets for a given profile.
    ///
    /// - Parameters:
    ///   - person: The user's profile data
    ///   - createAudit: Whether to create an audit trail of calculations
    /// - Returns: A `CalculatorResultViewModel` containing all calculation results
    static func calculate(person: ProfileViewModel, createAudit: Bool = false) async -> CalculatorResultViewModel {

        let result = CalculatorResultViewModel()

        if let errors = person.validateForCalculation() {
            result.updateErrorMessage(message: errors)
            return result
        }

        await Calculator.calculateTdee(result: result, person: person, createAudit: createAudit)
        person.calculateMacros(result: result)
        return result

    }

}
