//
//  ShareResultsModel.swift
//  SimpleTest
//
//  Created by Claude Code on 15/10/2024.
//

import Foundation

/// Model containing all data needed for sharing calculation results.
///
/// This model provides a clean separation between calculation logic
/// and share functionality, with pre-formatted text for easy sharing.
@MainActor
struct ShareResultsModel {

    // MARK: - Input Data

    /// User's gender as a displayable string
    let genderText: String
    /// User's age in years
    let ageText: String
    /// User's height with units
    let heightText: String
    /// User's weight with units
    let weightText: String
    /// User's activity level with full description
    let activityLevelText: String
    /// Body fat method description
    let bodyFatMethodText: String
    /// Body fat percentage (if applicable)
    let bodyFatText: String
    /// Calorie adjustment method description
    let calorieAdjustmentText: String
    /// Calorie adjustment amount
    let calorieAdjustmentAmountText: String
    /// Macro split method name
    let macroSplitMethodText: String
    /// Selected macro preset name
    let macroPresetText: String

    // MARK: - Calculation Outputs

    /// Basal Metabolic Rate with units
    let bmrText: String
    /// Total Daily Energy Expenditure with units
    let tdeeText: String
    /// Adjusted calories with units
    let adjustedCaloriesText: String
    /// Macro targets formatted for sharing
    let macroTargetsText: String

    // MARK: - Convenience Properties

    /// Full text summary suitable for sharing
    var shareText: String {
        """
        SimpleTest Results
        ==================

        INPUTS:
        - Gender: \(genderText)
        - Age: \(ageText)
        - Height: \(heightText)
        - Weight: \(weightText)
        - Activity Level: \(activityLevelText)
        \(bodyFatText.isEmpty ? "" : "- Body Fat: \(bodyFatText)\n")
        - Calorie Adjustment: \(calorieAdjustmentText)
        \(calorieAdjustmentAmountText.isEmpty ? "" : "- Adjustment Amount: \(calorieAdjustmentAmountText)\n")
        - Macro Split: \(macroSplitMethodText)
        - Macro Preset: \(macroPresetText)

        RESULTS:
        - BMR: \(bmrText)
        - TDEE: \(tdeeText)
        - Adjusted Calories: \(adjustedCaloriesText)

        MACRO TARGETS:
        \(macroTargetsText)
        """
    }

    // MARK: - Initializers

    /// Creates a ShareResultsModel from a ProfileViewModel and CalculatorResultViewModel.
    /// - Parameters:
    ///   - profile: The user's profile data
    ///   - result: The calculation results
    ///   - macroMethodName: The name of the selected macro split method
    ///   - macroPresetName: The name of the selected macro preset
    init(
        profile: ProfileViewModel,
        result: CalculatorResultViewModel,
        macroMethodName: String = "Custom",
        macroPresetName: String = "Custom"
    ) {
        // Format gender
        self.genderText = profile.gender.displayName

        // Format age
        self.ageText = "\(profile.age) years"

        // Format height (assuming cm from profile, could add UOM support)
        self.heightText = "\(profile.height) cm"

        // Format weight (assuming kg from profile, could add UOM support)
        self.weightText = "\(profile.weight) kg"

        // Format activity level with full description
        self.activityLevelText = profile.activityLevel.description

        // Format body fat method
        self.bodyFatMethodText = profile.bodyFatPercentageMethod.displayName

        // Format body fat percentage
        if profile.bodyFatPercentageMethod != .omit, profile.bodyFatPercentage > 0 {
            self.bodyFatText = "\(profile.bodyFatPercentage)%"
        } else {
            self.bodyFatText = "N/A"
        }

        // Format calorie adjustment
        self.calorieAdjustmentText = profile.calorieAdjustmentMethod.displayName

        // Format calorie adjustment amount
        let adjustment = profile.calorieAdjustment
        if adjustment != 0 {
            let sign = adjustment > 0 ? "+" : ""
            self.calorieAdjustmentAmountText = "\(sign)\(Int(adjustment)) kcal"
        } else {
            self.calorieAdjustmentAmountText = "None"
        }

        // Format macro split method
        self.macroSplitMethodText = macroMethodName

        // Format macro preset name
        self.macroPresetText = macroPresetName

        // Format calculation outputs
        self.bmrText = "\(Int(result.bmr)) kcal/day"
        self.tdeeText = "\(Int(result.tdee)) kcal/day"
        self.adjustedCaloriesText = "\(Int(result.adjustedCalories)) kcal/day"

        // Format macro targets
        self.macroTargetsText = """
        - Protein: \(result.proteinGrams)g (\(result.proteinPercent)%)
        - Carbs: \(result.carbsGrams)g (\(result.carbsPercent)%)
        - Fats: \(result.fatsGrams)g (\(result.fatsPercent)%)
        """
    }

    /// Creates a ShareResultsModel with default/empty values (for testing).
    static var empty: ShareResultsModel {
        ShareResultsModel(
            genderText: "",
            ageText: "",
            heightText: "",
            weightText: "",
            activityLevelText: "",
            bodyFatMethodText: "",
            bodyFatText: "",
            calorieAdjustmentText: "",
            calorieAdjustmentAmountText: "",
            macroSplitMethodText: "",
            macroPresetText: "",
            bmrText: "",
            tdeeText: "",
            adjustedCaloriesText: "",
            macroTargetsText: ""
        )
    }
}
