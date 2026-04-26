import Foundation
import Combine
import Observation

@Observable
final class ProfileViewModel: ObservableObject {
    // custom properties
    internal var isUpdatingExpansion = false
    
    /****************************************************/
    /*  Gender                                          */
    /****************************************************/
    var gender: enumGender
    var genderIsExpanded: Bool
    {
        didSet {
            enforceExclusiveExpansion(changed: .gender, newValue: genderIsExpanded)
        }
    }
    
    /****************************************************/
    /*  Age                                             */
    /****************************************************/
    var age: Int
    var ageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .age, newValue: ageIsExpanded)
        }
    }
    
    /****************************************************/
    /*  Weight                                          */
    /****************************************************/
    var weightUom: enumOptionWeight = enumOptionWeight.kilograms
    var weight: Double
    var weightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .weight, newValue: weightIsExpanded)
        }
    }
    
    /****************************************************/
    /*  Weight                                          */
    /****************************************************/
    var heightUom: enumOptionLength = enumOptionLength.centimeters
    var height: Double
    var heightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .height, newValue: heightIsExpanded)
        }
    }
    
    /****************************************************/
    /*  Activity Level                                  */
    /****************************************************/
    var activityLevel: enumActivityLevel
    var activityLevelIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .activityLevel, newValue: activityLevelIsExpanded)
        }
    }
    
    /****************************************************/
    /*  Body Fat Percentage                             */
    /****************************************************/
    var bodyFatPercentageMethod: enumBodyFatOption{
        didSet {
            bodyFatPercentageShowManualEntry = bodyFatPercentageMethod == .manualEntry
        }
    }
    var bodyFatPercentage: Double
    var bodyFatPercentageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .bodyFatPercentage, newValue: bodyFatPercentageIsExpanded)
        }
    }
    var bodyFatPercentageShowManualEntry: Bool
    
    /****************************************************/
    /*  Calorie Adjustment                              */
    /****************************************************/
    var calorieAdjustmentMethod: enumCalorieAdjustmentMethod = .maintain {
        didSet {
            calorieAdjustmentShowSliders = calorieAdjustmentMethod != .maintain
        }
    }
    var calorieAdjustment : Double
    var calorieAdjustmentExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .calorieAdjustmentMethod, newValue: calorieAdjustmentExpanded)
        }
    }
    var calorieAdjustmentShowSliders : Bool
    
    /****************************************************/
    /*  Macro Mix                                       */
    /****************************************************/
    var protein: Int
    var carbs: Int
    var fats: Int
    
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
        self.calorieAdjustmentExpanded = false
        self.isUpdatingExpansion = false
        self.calorieAdjustmentShowSliders = false
        self.bodyFatPercentageShowManualEntry = false
        self.bodyFatPercentageMethod = .omit
        
        // Macro Mix
        self.protein = 40
        self.carbs = 30
        self.fats = 30
    }
}
