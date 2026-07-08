import Foundation
import Combine
import Observation

@Observable
final class ProfileViewModel: ObservableObject {

    /****************************************************/
    /*  Gender                                          */
    /****************************************************/
    var gender: Gender
    
    /****************************************************/
    /*  Age                                             */
    /****************************************************/
    var age: Int
    
    /****************************************************/
    /*  Weight                                          */
    /****************************************************/
    var weightUom: OptionWeight = OptionWeight.kilograms
    var weight: Double
    
    /****************************************************/
    /*  Weight                                          */
    /****************************************************/
    var heightUom: OptionLength = OptionLength.centimeters
    var height: Double
    
    /****************************************************/
    /*  Activity Level                                  */
    /****************************************************/
    var activityLevel: ActivityLevel

    /****************************************************/
    /*  Body Fat Percentage                             */
    /****************************************************/
    var bodyFatPercentageMethod: BodyFatOption{
        didSet {
            bodyFatPercentageShowManualEntry = bodyFatPercentageMethod == .manualEntry
        }
    }
    var bodyFatPercentage: Double
    var bodyFatPercentageShowManualEntry: Bool
    
    /****************************************************/
    /*  Calorie Adjustment                              */
    /****************************************************/
    var calorieAdjustmentMethod: CalorieAdjustmentMethod = .maintain {
        didSet {
            calorieAdjustmentShowSliders = calorieAdjustmentMethod != .maintain
        }
    }
    var calorieAdjustment : Double
    var calorieAdjustmentShowSliders : Bool
    
    /****************************************************/
    /*  Macro Split                                     */
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
        
        // Macro Split
        self.protein = 40
        self.carbs = 30
        self.fats = 30
    }
}
