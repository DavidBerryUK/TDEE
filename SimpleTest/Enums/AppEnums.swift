//
//  SettingsEnums.swift
//  TDEEv4
//
//  Created by David Berry on 04/08/2020.
//  Copyright © 2020 David Berry. All rights reserved.
//

import Foundation

class AppEnums {

    enum enumSection {
        case activityLevel
        case age
        case bodyFat
        case genger
        case height
        case weight
    }
    
    enum enumGender : Int {
        case male = 0
        case female = 1
    }
    
    enum enumOptionWeight : Int {
        case kilograms = 0
        case pounds = 1
        case StonesAndPounds = 2
    }

    enum enumOptionLength : Int {
        case centimeters = 0
        case inches = 1
        case feetAndInches = 2
    }
    
    enum enumBodyFatOption : Int {
        case DoNoUse = 0
        case Estimate = 1
        case ManualEntry = 2
    }
    
    enum enumCalorieAdjustmentMethod : Int {
        case Cut = 0
        case Maintain = 1
        case Bulk = 2
    }
    
    enum enumMacroSplitMethod : Int {
        case Ketogenic = 0
        case LowCarb = 1
        case Paleo = 2
        case Bulk = 3
        case Custom = 4
    }
    
    enum enumActivityLevel : Int, CaseIterable {
        case Sedentary = 0
        case LightExercise = 1
        case ModerateExercise = 2
        case HeavyExercise = 3
        case Athlete = 4
    }
}

extension AppEnums.enumActivityLevel {
    var displayName: String {
        switch self {
        case .Sedentary: return "Sedentary (office job)"
        case .LightExercise: return "Light Exercise (1-2 days)"
        case .ModerateExercise: return "Moderate Exercise (3-5 days)"
        case .HeavyExercise: return "Heavy Exercise (3-5 days)"
        case .Athlete: return "Athlete (2x per day)"
        }
    }
}
