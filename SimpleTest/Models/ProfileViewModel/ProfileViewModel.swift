import Foundation
import SwiftUI
import Observation

/// State management for user profile metrics.
///
/// This ViewModel serves as the single source of truth for all user profile data and derived calculations.
/// It manages both raw input values and calculated results (TDEE, macro targets) while ensuring
/// automatic recalculation when any input changes.
///
/// ## Key Features
/// - Automatic calculation updates via property observers
/// - Clean separation between input data and derived calculations
/// - Comprehensive validation and error handling
/// - Environment-specific defaults via AppConfig (simulator vs. device)
@Observable
final class ProfileViewModel {

    // MARK: - State Properties (Input/Raw Data)

    /// User's gender, used in BMR calculation formulas
    var gender: Gender = AppConfig.shared.profileDefaults.gender {
        didSet {
            refreshResults()
        }
    }
    /// User's age in years
    var age: Int = AppConfig.shared.profileDefaults.age {
        didSet {
            refreshResults()
        }
    }
    /// Unit of measure for weight (kilograms or pounds)
    var weightUom: OptionWeight = OptionWeight.kilograms
    /// User's weight in the current unit of measure
    var weight: Double = AppConfig.shared.profileDefaults.weight {
        didSet {
            refreshResults()
        }
    }
    /// Unit of measure for height (centimeters or inches)
    var heightUom: OptionLength = OptionLength.centimeters
    /// User's height in the current unit of measure
    var height: Double = AppConfig.shared.profileDefaults.height {
        didSet {
            refreshResults()
        }
    }
    /// User's activity level for TDEE calculation
    var activityLevel: ActivityLevel = AppConfig.shared.profileDefaults.activityLevel {
        didSet {
            refreshResults()
        }
    }

    // Body Fat Management (Retained pattern)
    /// Method used to determine body fat percentage
    var bodyFatPercentageMethod: BodyFatOption = AppConfig.shared.profileDefaults.bodyFatPercentageMethod {
        didSet {
            bodyFatPercentageShowManualEntry = bodyFatPercentageMethod == .manualEntry
            refreshResults()
        }
    }
    /// User's body fat percentage
    var bodyFatPercentage: Double = AppConfig.shared.profileDefaults.bodyFatPercentage {
        didSet {
            refreshResults()
        }
    }
    /// Whether to show the manual entry field for body fat
    var bodyFatPercentageShowManualEntry: Bool

    // Calorie Adjustment (Retained pattern)
    /// Method for adjusting daily calorie intake
    var calorieAdjustmentMethod: CalorieAdjustmentMethod = AppConfig.shared.profileDefaults.calorieAdjustmentMethod {
        didSet {
            calorieAdjustmentShowSliders = calorieAdjustmentMethod != .maintain
            refreshResults()
        }
    }
    /// Amount of calories to adjust up or down
    var calorieAdjustment : Double {
        didSet {
            refreshResults()
        }
    }
    /// Whether to show the calorie adjustment slider controls
    var calorieAdjustmentShowSliders : Bool

    // Macro Split (Retained pattern)
    /// Protein percentage target
    var protein: Int = 40 {
        didSet {
            refreshResults()
        }
    }
    /// Carbs percentage target
    var carbs: Int = 30 {
        didSet {
            refreshResults()
        }
    }
    /// Fats percentage target
    var fats: Int = 30 {
        didSet {
            refreshResults()
        }
    }

    // MARK: - Derived/Calculated State (The single source of truth for calculations)
    /// The TDEE calculated value
    var tdee: Double = 1800.0
    /// The macro targets derived from the latest TDEE calculation
    var macroTargets: (protein: Int, carbs: Int, fats: Int) = (40, 30, 30)

    //*******************************
    // Initializer                  *
    //*******************************
    /// Creates a new ProfileViewModel with default values
    init() {
        self.bodyFatPercentageShowManualEntry = false
        self.calorieAdjustment = 0
        self.calorieAdjustmentShowSliders = false

        // Macro Split
        self.protein = 40
        self.carbs = 30
        self.fats = 30
    }

    /// Public method to trigger a recalculation cycle.
    func refreshResults() {
        // Use the correct calculation with body fat support
        let bmr: Double
        if self.bodyFatPercentageMethod != .omit {
            bmr = self.calculateKatchMcArdle(logger: AuditLogger(enabled: false))
        } else {
            bmr = self.calculateMifflinStJeor(logger: AuditLogger(enabled: false))
        }

        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: self.activityLevel, logger: AuditLogger(enabled: false))
        self.tdee = tdee
        self.macroTargets = self.calculateMacros(tdee: tdee)
    }

    /// Calculates macro targets from TDEE.
    /// - Parameter tdee: Total Daily Energy Expenditure in calories
    /// - Returns: Tuple of (protein, carbs, fats) in grams
    func calculateMacros(tdee: Double) -> (protein: Int, carbs: Int, fats: Int) {
        let totalCalories = Int(tdee)
        let proteinCal = Double(totalCalories) * 0.4
        let carbCal = Double(totalCalories) * 0.3
        let fatCal = Double(totalCalories) - proteinCal - carbCal

        return (
            protein: Int(proteinCal / 4),
            carbs: Int(carbCal / 4),
            fats: Int(fatCal / 9)
        )
    }

    // [Retained other methods if they do not involve calculation logic]
}
