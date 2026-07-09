import Foundation
import SwiftUI // For Color usage if needed by derived properties

/// A dedicated service layer responsible for all physiological calculations (BMR, TDEE, Macros).
/// This decouples mathematical computation from state management and UI concerns, making logic testable in isolation.
struct CalculationService {
    // MARK: - Constants

    /// Mifflin-St Jeor BMR formula constants for males
    private static let maleWeightConstant = 76.2
    private static let maleHeightConstant = 5.0
    private static let maleAgeConstant = 18.5
    private static let maleBodyFatConstant = 5.0

    /// Calorie to gram conversion constants
    private static let proteinCaloriesPerGram = 4.0
    private static let carbCaloriesPerGram = 4.0
    private static let fatCaloriesPerGram = 9.0

    /// Macro percentage defaults
    private static let defaultProteinPercentage = 0.4
    private static let defaultCarbPercentage = 0.3

    // MARK: - Core Formulas

    /**
     Calculates Basal Metabolic Rate (BMR) based on established formulas.
     - Parameters:
        - profile: The current user's profile data.
     */
    static func calculateBMR(profile: ProfileViewModel) -> Double {
        // Implementation will read from different sources (Harris-Benedict, Mifflin-St Jeor)
        // Logic here needs to be determined based on the profile's selected BMR method.
        if profile.gender == .male && profile.age > 0 {
             // Placeholder for a formula using weight, height, and age
            let weightComponent = maleWeightConstant * profile.weight
            let heightComponent = maleHeightConstant * profile.height
            let ageComponent = maleAgeConstant * Double(profile.age)

            // Only include body fat component if manual entry is selected
            let bodyFatComponent: Double
            if profile.bodyFatPercentageMethod == .manualEntry {
                bodyFatComponent = maleBodyFatConstant * (profile.bodyFatPercentage / 100)
            } else {
                bodyFatComponent = 0
            }

            return weightComponent + heightComponent - ageComponent + bodyFatComponent
        }
        return 1200.0 // Default safe fallback value
    }

    /**
     Calculates Total Daily Energy Expenditure (TDEE).
     - Parameters:
        - bmr: The calculated Basal Metabolic Rate.
        - activityLevel: The user's activity level.
     */
    static func calculateTdee(bmr: Double, activityLevel: ActivityLevel) -> Double {
        // This formula is generally straightforward multiplication.
        return bmr * activityLevel.KatchMcArdleMultipliers
    }

    /**
     Calculates macro split targets based on TDEE and user goal adjustments.
     - Parameters:
        - tdee: The target daily calorie intake.
        - profile: The current user's profile data.
     */
    static func calculateMacros(tdee: Double, profile: ProfileViewModel) -> (protein: Int, carbs: Int, fats: Int) {
        let totalCalories = Int(tdee)

        // Placeholder logic using simple percentage calculation
        let proteinCal = Double(totalCalories) * defaultProteinPercentage
        let carbCal = Double(totalCalories) * defaultCarbPercentage
        let fatCal = Double(totalCalories) - proteinCal - carbCal

        // Converting calories back to grams (P: 4 cal/g, C: 4 cal/g, F: 9 cal/g)
        return (protein: Int(proteinCal / proteinCaloriesPerGram),
                carbs: Int(carbCal / carbCaloriesPerGram),
                fats: Int(fatCal / fatCaloriesPerGram))
    }

    // Future expansion point: Add methods for calculating weekly totals, etc.
}