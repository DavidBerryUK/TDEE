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
    
    private enum EnumExpansionField { case gender, age, weight, height, activityLevel, bodyFatPercentage }
    
    private func enforceExclusiveExpansion(changed: EnumExpansionField, newValue: Bool) {
        if isUpdatingExpansion { return }
        guard newValue == true else { return }
        isUpdatingExpansion = true
        switch changed {
        case .gender:
            if ageIsExpanded { ageIsExpanded = false }
            if heightIsExpanded { heightIsExpanded = false }
            if weightIsExpanded { weightIsExpanded = false }
            if activityLevelIsExpanded { activityLevelIsExpanded = false }
            if bodyFatPercentageIsExpanded { bodyFatPercentageIsExpanded = false }
        case .age:
            if genderIsExpanded { genderIsExpanded = false }
            if weightIsExpanded { weightIsExpanded = false }
            if heightIsExpanded { heightIsExpanded = false }
            if bodyFatPercentageIsExpanded { bodyFatPercentageIsExpanded = false }
            if activityLevelIsExpanded { activityLevelIsExpanded = false }
        case .weight:
            if genderIsExpanded { genderIsExpanded = false }
            if ageIsExpanded { ageIsExpanded = false }
            if heightIsExpanded { heightIsExpanded = false }
            if bodyFatPercentageIsExpanded { bodyFatPercentageIsExpanded = false }
            if activityLevelIsExpanded { activityLevelIsExpanded = false }
        case .height:
            if genderIsExpanded { genderIsExpanded = false }
            if ageIsExpanded { ageIsExpanded = false }
            if weightIsExpanded { weightIsExpanded = false }
            if bodyFatPercentageIsExpanded { bodyFatPercentageIsExpanded = false }
            if activityLevelIsExpanded { activityLevelIsExpanded = false }
        case .activityLevel:
            if genderIsExpanded { genderIsExpanded = false }
            if ageIsExpanded { ageIsExpanded = false }
            if heightIsExpanded { heightIsExpanded = false }
            if weightIsExpanded { weightIsExpanded = false }
            if bodyFatPercentageIsExpanded { bodyFatPercentageIsExpanded = false }
        case .bodyFatPercentage:
            if genderIsExpanded { genderIsExpanded = false }
            if ageIsExpanded { ageIsExpanded = false }
            if heightIsExpanded { heightIsExpanded = false }
            if weightIsExpanded { weightIsExpanded = false }
            if activityLevelIsExpanded { activityLevelIsExpanded = false }
        }
        isUpdatingExpansion = false
    }
    
    init(gender: enumGender = enumGender.male, age: Int = 18, weight: Double = 70, height: Double = 170, activityLevel: enumActivityLevel = enumActivityLevel.sedentary) {
        self.gender = gender
        self.age = age
        self.weight = weight
        self.height = height
        self.bodyFatPercentage = 15
        self.activityLevel = activityLevel
        
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
    
    func collapseAll() {
        self.isUpdatingExpansion = true
        self.ageIsExpanded = false
        self.genderIsExpanded = false
        self.weightIsExpanded = false
        self.heightIsExpanded = false
        self.activityLevelIsExpanded = false
        self.bodyFatPercentageIsExpanded = false
        self.isUpdatingExpansion = false
    }
}
