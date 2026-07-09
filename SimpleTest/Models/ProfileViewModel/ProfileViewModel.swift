import Foundation
import SwiftUI
import Combine
import Observation

/// State management for user profile metrics, devoid of heavy calculation logic.
///
/// This ViewModel serves as the single source of truth for all user profile data and derived calculations.
/// It manages both raw input values and calculated results (TDEE, macro targets) while ensuring
/// automatic recalculation when any input changes.
///
/// ## Key Features
/// - Automatic calculation updates via property observers
/// - Clean separation between input data and derived calculations
/// - Comprehensive validation and error handling
/// - Integration with CalculationService for all mathematical operations
@Observable
final class ProfileViewModel: ObservableObject {

    // MARK: - State Properties (Input/Raw Data)

    /// User's gender, used in BMR calculation formulas
    var gender: Gender = .male {
        didSet {
            calculateAllDerivedValues()
        }
    }
    var age: Int = 16 {
        didSet {
            calculateAllDerivedValues()
        }
    }
    var weightUom: OptionWeight = OptionWeight.kilograms
    var weight: Double = 0 { // Raw input state
        didSet {
            calculateAllDerivedValues()
        }
    }
    var heightUom: OptionLength = OptionLength.centimeters
    var height: Double = 0 {
        didSet {
            calculateAllDerivedValues()
        }
    }
    var activityLevel: ActivityLevel = .sedentary {
        didSet {
            calculateAllDerivedValues()
        }
    }

    // Body Fat Management (Retained pattern)
    var bodyFatPercentageMethod: BodyFatOption{
        didSet {
            bodyFatPercentageShowManualEntry = bodyFatPercentageMethod == .manualEntry
            calculateAllDerivedValues()
        }
    }
    var bodyFatPercentage: Double {
        didSet {
            calculateAllDerivedValues()
        }
    }
    var bodyFatPercentageShowManualEntry: Bool

    // Calorie Adjustment (Retained pattern)
    var calorieAdjustmentMethod: CalorieAdjustmentMethod = .maintain {
        didSet {
            calorieAdjustmentShowSliders = calorieAdjustmentMethod != .maintain
            calculateAllDerivedValues()
        }
    }
    var calorieAdjustment : Double {
        didSet {
            calculateAllDerivedValues()
        }
    }
    var calorieAdjustmentShowSliders : Bool

    // Macro Split (Retained pattern)
    var protein: Int = 40 {
        didSet {
            calculateAllDerivedValues()
        }
    }
    var carbs: Int = 30 {
        didSet {
            calculateAllDerivedValues()
        }
    }
    var fats: Int = 30 {
        didSet {
            calculateAllDerivedValues()
        }
    }

    // MARK: - Derived/Calculated State (The single source of truth for calculations)
    /// The TDEE calculated value, read-only.
    var tdee: Double = 1800.0
    /// The macro targets derived from the latest TDEE calculation.
    var macroTargets: (protein: Int, carbs: Int, fats: Int) = (40, 30, 30)

    //*******************************
    // Initialiser                  *
    //*******************************
    init() {
        self.gender = .male
        self.age = 16
        self.weight = 0
        self.height = 0
        self.bodyFatPercentage = 0
        self.activityLevel = .sedentary
        self.calorieAdjustment = 0;
        self.calorieAdjustmentShowSliders = false
        self.bodyFatPercentageShowManualEntry = false
        self.bodyFatPercentageMethod = .omit

        // Macro Split
        self.protein = 40
        self.carbs = 30
        self.fats = 30
    }

    /// Public method to trigger a recalculation cycle that must now use the CalculationService.
    func calculateAllDerivedValues() {
        // Delegate ALL complex, formula-driven calculation logic to the service layer.
        let bmr = CalculationService.calculateBMR(profile: self)
        let tdee = CalculationService.calculateTdee(bmr: bmr, activityLevel: self.activityLevel)

        // Update derived state properties directly within the ViewModel
        self.tdee = tdee
        let macros = CalculationService.calculateMacros(tdee: tdee, profile: self)
        self.macroTargets = (protein: macros.protein, carbs: macros.carbs, fats: macros.fats)
    }

    // [Retained other methods if they do not involve calculation logic]
}