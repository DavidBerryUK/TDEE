import Foundation
import SwiftUI // For Color usage if needed by derived properties

/// A dedicated service layer responsible for all physiological calculations (BMR, TDEE, Macros).
/// This decouples mathematical computation from state management and UI concerns, making logic testable in isolation.
struct CalculationService {
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
            let weightComponent = 76.2 * profile.weight
            let heightComponent = 5 * profile.height
            let ageComponent = 18.5 * Double(profile.age)
            let bodyFatComponent = 5 * (profile.bodyFatPercentage / 100)
            return weightComponent + heightComponent - ageComponent + bodyFatComponent
        }
        return 1200.0 // Default safe fallback value
    }

    /**
     Calculates Total Daily Energy Expenditure (TDEE).
     - Parameters:
        - bmr: The calculated Basal Metabolic Rate.
        - activityLevelMultiplier: A factor based on the user's activity level.
     */
    static func calculateTdee(bmr: Double, activityLevelMultiplier: Double) -> Double {
        // This formula is generally straightforward multiplication.
        return bmr * activityLevelMultiplier
    }

    /**
     Calculates macro split targets based on TDEE and user goal adjustments.
     - Parameters:
        - tdee: The target daily calorie intake.
        - proteinTargetPercent: Target percentage of calories from protein (e.g., 40%).
        // ... other parameters for carb/fat percentages
     */
    static func calculateMacros(tdee: Double, profile: ProfileViewModel) -> (protein: Int, carbs: Int, fats: Int) {
        let totalCalories = Int(tdee)

        // Placeholder logic using simple percentage calculation
        let proteinCal = Double(totalCalories) * 0.4 // Assuming a default goal of 40% protein for now
        let carbCal = Double(totalCalories) * 0.3
        let fatCal = Double(totalCalories) - proteinCal - carbCal

        // Converting calories back to grams (P: 4 cal/g, C: 4 cal/g, F: 9 cal/g)
        return (protein: Int(proteinCal / 4), carbs: Int(carbCal / 4), fats: Int(fatCal / 9))
    }

    // Future expansion point: Add methods for calculating weekly totals, etc.
}