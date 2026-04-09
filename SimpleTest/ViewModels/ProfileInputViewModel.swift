import Foundation
import Combine
import Observation

@Observable
final class ProfileInputViewModel: ObservableObject {
    // custom properties
    private var isUpdatingExpansion = false
    
    var gender: enumGender

    var genderIsExpanded: Bool
    {
        didSet {
            enforceExclusiveExpansion(changed: .gender, newValue: genderIsExpanded)
        }
    }
    
    var age: Int
    
    var ageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .age, newValue: ageIsExpanded)
        }
    }
    
    var weightUom: enumOptionWeight = enumOptionWeight.kilograms
    var weight: Double
    
    var weightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .weight, newValue: weightIsExpanded)
        }
    }
    
    var heightUom: enumOptionLength = enumOptionLength.centimeters
    var height: Double
    var heightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .height, newValue: heightIsExpanded)
        }
    }
    
    var activityLevel: enumActivityLevel
    var activityLevelIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .activityLevel, newValue: activityLevelIsExpanded)
        }
    }
    
    var bodyFatPercentageMethod: enumBodyFatOption
    var bodyFatPercentage: Double
    
    var bodyFatPercentageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .bodyFatPercentage, newValue: bodyFatPercentageIsExpanded)
        }
    }
    
    var calorieAdjustmentMethod: enumCalorieAdjustmentMethod = .maintain
    var calorieAdjustment : Double
    
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
        
        // Initialize expansion flags without triggering observers
        self.isUpdatingExpansion = true
        self.ageIsExpanded = false
        self.genderIsExpanded = false
        self.weightIsExpanded = false
        self.heightIsExpanded = false
        self.activityLevelIsExpanded = false
        self.bodyFatPercentageIsExpanded = false
        self.isUpdatingExpansion = false
        self.bodyFatPercentageMethod = .omit
    }
    
    //*******************************
    // Computed Properties          */
    //*******************************
    var hasError: Bool {
        weight == 0 || height == 0 
    }
    
    var usValue: Bool {
        weight != 0 && height != 0
    }
    
    private func enforceExclusiveExpansion(changed: enumSection, newValue: Bool) {
        if isUpdatingExpansion { return }
        guard newValue == true else { return }
        isUpdatingExpansion = true
        
        if ( changed != .age && ageIsExpanded) { ageIsExpanded = false }
        if ( changed != .gender && genderIsExpanded) { genderIsExpanded = false }
        if ( changed != .height && heightIsExpanded) { heightIsExpanded = false }
        if ( changed != .weight && weightIsExpanded) { weightIsExpanded = false }
        if ( changed != .bodyFatPercentage && bodyFatPercentageIsExpanded) { bodyFatPercentageIsExpanded = false }
        if ( changed != .activityLevel && activityLevelIsExpanded) { activityLevelIsExpanded = false }

        isUpdatingExpansion = false
    }
    
    // get the result of tde calculations
    var tdeeResult: TdeeResult {
        TdeeCalculator.calculate(person: self)
    }
    
    func collapseAll() {
        enforceExclusiveExpansion(changed: .none, newValue: true)
    }
}
