import Foundation
import Combine
import Observation

@Observable
final class ProfileViewModel: ObservableObject {

    /****************************************************/
    /*  Gender                                          */
    /****************************************************/
    var gender: enumGender
    
    /****************************************************/
    /*  Age                                             */
    /****************************************************/
    var age: Int
    
    /****************************************************/
    /*  Weight                                          */
    /****************************************************/
    var weightUom: enumOptionWeight = enumOptionWeight.kilograms
    var weight: Double
    
    /****************************************************/
    /*  Weight                                          */
    /****************************************************/
    var heightUom: enumOptionLength = enumOptionLength.centimeters
    var height: Double
    
    /****************************************************/
    /*  Activity Level                                  */
    /****************************************************/
    var activityLevel: enumActivityLevel

    /****************************************************/
    /*  Body Fat Percentage                             */
    /****************************************************/
    var bodyFatPercentageMethod: enumBodyFatOption{
        didSet {
            bodyFatPercentageShowManualEntry = bodyFatPercentageMethod == .manualEntry
        }
    }
    var bodyFatPercentage: Double
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
        self.calorieAdjustmentShowSliders = false
        self.bodyFatPercentageShowManualEntry = false
        self.bodyFatPercentageMethod = .omit
        
        // Macro Mix
        self.protein = 40
        self.carbs = 30
        self.fats = 30
    }
}
