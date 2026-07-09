import Foundation
import SwiftUI // For Color usage if needed by derived properties

/// Service layer responsible for all physiological calculations (BMR, TDEE, Macros).
/// This decouples mathematical computation from state management and UI concerns, making logic testable in isolation.
///
/// ## Usage
/// ```swift
/// let bmr = CalculationService.calculateBMR(profile: userProfile)
/// let tdee = CalculationService.calculateTdee(bmr: bmr, activityLevel: .moderateExercise)
/// let macros = CalculationService.calculateMacros(tdee: tdee, profile: userProfile)
/// ```
struct CalculationService {
    // MARK: - Constants

    /// Mifflin-St Jeor BMR formula constants for males
    ///
    /// - Note: These constants are derived from the standard Mifflin-St Jeor equation for men:
    ///   BMR = 76.2 * weight(kg) + 5 * height(cm) - 18.5 * age(years) + 5 * bodyFatPercentage(%)
    private static let maleWeightConstant = 76.2
    private static let maleHeightConstant = 5.0
    private static let maleAgeConstant = 18.5
    private static let maleBodyFatConstant = 5.0

    /// Calorie to gram conversion constants for macronutrient calculations
    ///
    /// - Note: These are standard caloric values used in nutrition science:
    ///   - Protein: 4 calories per gram
    ///   - Carbohydrates: 4 calories per gram
    ///   - Fats: 9 calories per gram
    private static let proteinCaloriesPerGram = 4.0
    private static let carbCaloriesPerGram = 4.0
    private static let fatCaloriesPerGram = 9.0

    /// Default macro percentage distribution for calculations
    ///
    /// - Note: These percentages represent standard dietary guidelines:
    ///   - Protein: 40% of total calories
    ///   - Carbohydrates: 30% of total calories
    ///   - Fats: Remaining calories (30%)
    private static let defaultProteinPercentage = 0.4
    private static let defaultCarbPercentage = 0.3

    // MARK: - Core Formulas

    /// Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation for males.
    ///
    /// For females, this function returns a default fallback value of 1200.0 calories.
    ///
    /// ## Formula
    /// BMR = weightConstant * weight(kg) + heightConstant * height(cm) - ageConstant * age(years) + bodyFatConstant * (bodyFatPercentage / 100)
    ///
    /// ## Parameters
    /// - profile: The current user's profile data containing gender, age, weight, height, and body fat percentage information
    ///
    /// ## Returns
    /// - Basal Metabolic Rate in calories per day
    ///
    /// ## Important Notes
    /// - Body fat percentage is only included in the calculation when `bodyFatPercentageMethod` is `.manualEntry`
    /// - The function returns a default fallback of 1200.0 for females or invalid ages (≤ 0)
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

    /// Calculates Total Daily Energy Expenditure (TDEE) by applying activity level multipliers to BMR.
    ///
    /// ## Formula
    /// TDEE = BMR × Activity Level Multiplier
    ///
    /// ## Parameters
    /// - bmr: The calculated Basal Metabolic Rate in calories per day
    /// - activityLevel: The user's activity level, which determines the appropriate Katch-McArdle multiplier
    ///
    /// ## Returns
    /// - Total Daily Energy Expenditure in calories per day
    ///
    /// ## Important Notes
    /// - Uses the Katch-McArdle multipliers from ActivityLevel enum for accurate activity adjustment
    /// - This represents the total calories needed to maintain current weight based on activity level
    static func calculateTdee(bmr: Double, activityLevel: ActivityLevel) -> Double {
        // This formula is generally straightforward multiplication.
        return bmr * activityLevel.KatchMcArdleMultipliers
    }

    /// Calculates macro split targets based on TDEE and standard nutritional guidelines.
    ///
    /// ## Formula
    /// Macro distribution is calculated as:
    /// - Protein calories = TDEE × defaultProteinPercentage (40%)
    /// - Carbohydrate calories = TDEE × defaultCarbPercentage (30%)
    /// - Fat calories = TDEE - Protein calories - Carbohydrate calories
    ///
    /// ## Parameters
    /// - tdee: The target daily calorie intake in calories per day
    /// - profile: The current user's profile data (used for future expansion)
    ///
    /// ## Returns
    /// - Tuple containing macro targets as integers (protein: Int, carbs: Int, fats: Int) in grams
    ///
    /// ## Important Notes
    /// - Macro distribution follows standard dietary guidelines (40% protein, 30% carbs, remaining fats)
    /// - Conversion from calories to grams uses standard nutritional values:
    ///   - Protein: 4 calories per gram
    ///   - Carbohydrates: 4 calories per gram
    ///   - Fats: 9 calories per gram
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