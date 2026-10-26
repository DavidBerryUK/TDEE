//
//  ShareResultsModel.swift
//  TDEE
//
//  Created by Claude Code on 15/10/2024.
//

import Foundation

// MARK: - Helper Functions

/// Formats a Double as an integer string if it has no decimal places, otherwise returns the full value.
/// - Parameter value: The Double value to format
/// - Returns: A string representation of the value without unnecessary decimal places
private func formatAsInteger(_ value: Double) -> String {
    if value.truncatingRemainder(dividingBy: 1) == 0 {
        return String(Int(value))
    }
    return String(value)
}

/// Joins a measurement's major value/unit and optional minor value/unit into a
/// single string, skipping empty segments — the four-part layout that
/// UISectionSummaryValueHeight / UISectionSummaryValueWeight render separately.
private func joinMeasurement(major: String, majorUnit: String, minor: String, minorUnit: String) -> String {
    [major, majorUnit, minor, minorUnit].filter { !$0.isEmpty }.joined(separator: " ")
}

/// Formats a height through its UOM, reusing the same `DisplayLength` value
/// helpers as UISectionSummaryValueHeight (major value + unit, plus the minor
/// value + unit for feet-and-inches).
private func formatHeight(length: Double, unit: OptionLength) -> String {
    let majorUnit: String
    let minorUnit: String
    switch unit {
    case .centimeters:
        majorUnit = "cm"
        minorUnit = ""
    case .inches:
        majorUnit = "inches"
        minorUnit = ""
    case .feetAndInches:
        majorUnit = "feet"
        minorUnit = "inches"
    }
    return joinMeasurement(
        major: DisplayLength.asMajorValue(length: length, unit: unit),
        majorUnit: majorUnit,
        minor: DisplayLength.asMinorValue(length: length, unit: unit),
        minorUnit: minorUnit
    )
}

/// Formats a weight through its UOM, reusing the same `DisplayWeight` value
/// helpers as UISectionSummaryValueWeight (major value + unit, plus the minor
/// value + unit for stones-and-pounds).
private func formatWeight(weight: Double, unit: OptionWeight) -> String {
    let majorUnit: String
    let minorUnit: String
    switch unit {
    case .kilograms:
        majorUnit = "kg"
        minorUnit = ""
    case .pounds:
        majorUnit = "pounds"
        minorUnit = ""
    case .stonesAndPounds:
        majorUnit = "stones"
        minorUnit = "pounds"
    }
    return joinMeasurement(
        major: DisplayWeight.asMajorValue(weight: weight, unit: unit),
        majorUnit: majorUnit,
        minor: DisplayWeight.asMinorValue(weight: weight, unit: unit),
        minorUnit: minorUnit
    )
}

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
        TDEE Results
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
    ///   - macroPresetName: The name of the selected macro preset
    init(
        profile: ProfileViewModel,
        result: CalculatorResultViewModel,
        macroPresetName: String = "Custom"
    ) {
        // Format gender
        self.genderText = profile.gender.displayName

        // Format age
        self.ageText = "\(profile.age) years"

        // Format height/weight through the profile's UOM, mirroring
        // UISectionSummaryValueHeight / UISectionSummaryValueWeight.
        self.heightText = formatHeight(length: profile.height, unit: profile.heightUom)
        self.weightText = formatWeight(weight: profile.weight, unit: profile.weightUom)

        // Format activity level with full description
        self.activityLevelText = profile.activityLevel.description

        // Format body fat method
        self.bodyFatMethodText = profile.bodyFatPercentageMethod.displayName

        // Format body fat percentage
        if profile.bodyFatPercentageMethod == .manualEntry, profile.bodyFatPercentage > 0 {
            self.bodyFatText = formatAsInteger(profile.bodyFatPercentage) + "%"
        } else {
            self.bodyFatText = "N/A"
        }

        // Format calorie adjustment
        self.calorieAdjustmentText = profile.calorieAdjustmentMethod.displayName

        // Format calorie adjustment amount.
        // Direction lives in `calorieAdjustmentMethod`; `calorieAdjustment` is a
        // non-negative magnitude (MetricRanges.calorieAdjustment = 0...1000), so the
        // sign must come from the method, not the value — a 500 kcal cut stores 500,
        // not -500, and must read "-500 kcal", not "+500 kcal" (PA-27). `.maintain`
        // ignores the magnitude entirely (see adjustCalories), so it reads "None".
        let adjustment = profile.calorieAdjustment
        if profile.calorieAdjustmentMethod == .maintain || adjustment == 0 {
            self.calorieAdjustmentAmountText = "None"
        } else {
            self.calorieAdjustmentAmountText = "\(profile.calorieAdjustmentMethod.adjustmentPrefix)\(Int(adjustment)) kcal"
        }

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
            macroPresetText: "",
            bmrText: "",
            tdeeText: "",
            adjustedCaloriesText: "",
            macroTargetsText: ""
        )
    }

    /// Creates a ShareResultsModel with all text fields (for testing with empty data).
    init(
        genderText: String,
        ageText: String,
        heightText: String,
        weightText: String,
        activityLevelText: String,
        bodyFatMethodText: String,
        bodyFatText: String,
        calorieAdjustmentText: String,
        calorieAdjustmentAmountText: String,
        macroPresetText: String,
        bmrText: String,
        tdeeText: String,
        adjustedCaloriesText: String,
        macroTargetsText: String
    ) {
        self.genderText = genderText
        self.ageText = ageText
        self.heightText = heightText
        self.weightText = weightText
        self.activityLevelText = activityLevelText
        self.bodyFatMethodText = bodyFatMethodText
        self.bodyFatText = bodyFatText
        self.calorieAdjustmentText = calorieAdjustmentText
        self.calorieAdjustmentAmountText = calorieAdjustmentAmountText
        self.macroPresetText = macroPresetText
        self.bmrText = bmrText
        self.tdeeText = tdeeText
        self.adjustedCaloriesText = adjustedCaloriesText
        self.macroTargetsText = macroTargetsText
    }
}
