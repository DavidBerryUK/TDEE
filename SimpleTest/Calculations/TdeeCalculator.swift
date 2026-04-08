//
//  Untitled.swift
//  SimpleTest
//
//  Created by David Berry on 06/04/2026.
//

import Foundation

// MARK: - Result Models

struct TdeeResult {
    let bmr: Double
    let tdee: Double
    let adjustedCalories: Double
    let message: String?
    let audit: [AuditItem]
}

// MARK: - Calculator

struct TdeeCalculator {
    
    static func calculate(person: ProfileInputViewModel, createAudit: Bool = false) -> TdeeResult {
        
        var logger = AuditLogger(enabled: createAudit)
        
        logger.log(AuditItem(title: "Total Daily Energy Expenditure"))
        logger.logInputs(person: person)
        
        // Validate input
        let missingFields = missingFields(for: person)
        if !missingFields.isEmpty {
            let message = "Enter \(missingFields.joined(separator: ", ")) to view results"
            logger.log(AuditItem(message: "\(missingFields.joined(separator: ", ")) not entered"))
            
            return TdeeResult(
                bmr: 0,
                tdee: 0,
                adjustedCalories: 0,
                message: message,
                audit: logger.items
            )
        }
        
        // Calculate BMR
        let bmr: Double
        switch person.bodyFatPercentageMethod {
        case .omit:
            bmr = calculateMifflinStJeor(person: person, logger: logger)
        case .estimate, .manualEntry:
            bmr = calculateKatchMcArdle(person: person, logger: logger)
        }
        
        // Adjust for activity
        let tdee = adjustForActivity(bmr: bmr, activityLevel: person.activityLevel, logger: logger)
        
        // Adjust calories
        let adjustedCalories = adjustCalories(base: tdee, person: person, logger: logger)
        
        // Macros
        logMacros(calories: adjustedCalories, person: person, logger: logger)
        
        return TdeeResult(
            bmr: bmr,
            tdee: tdee,
            adjustedCalories: adjustedCalories,
            message: nil,
            audit: logger.items
        )
    }
    
    private static func missingFields(for person: ProfileInputViewModel) -> [String] {
        var fields: [String] = []
        if person.age == 0 { fields.append("Age") }
        if person.height == 0 { fields.append("Height") }
        if person.weight == 0 { fields.append("Weight") }
        return fields
    }
    
    private static func calculateMifflinStJeor(person: ProfileInputViewModel, logger: AuditLogger) -> Double {
        //  logger.log(AuditItem(subTitle: "Mifflin St Jeor Formula"))
        
        let weight = Double(person.weight)
        let height = Double(person.height)
        let age = Double(person.age)
        let adjustment = person.gender == .male ? 5.0 : -161.0
        
        let bmr = 10.0 * weight + 6.25 * height - 5.0 * age + adjustment
        
        //        logger.logFormula(
        //            title: "BMR Formula",
        //            formula: "bmr = 10w + 6.25h - 5a + adj",
        //            calculation: "\(bmr) = 10*\(weight) + 6.25*\(height) - 5*\(age) + \(adjustment)"
        //        )
        
        return bmr
    }
    
    private static func calculateKatchMcArdle(person: ProfileInputViewModel, logger: AuditLogger) -> Double {
        //    logger.log(AuditItem(subTitle: "Katch-McArdle Formula"))
        
        let lbm = calculateLeanBodyMass(person: person, logger: logger)
        let bmr = 370 + (21.6 * lbm)
        
        //        logger.logFormula(
        //            title: "BMR Formula",
        //            formula: "bmr = 370 + (21.6 * lbm)",
        //            calculation: "\(bmr) = 370 + (21.6 * \(lbm))"
        //        )
        
        return bmr
    }
    
    private  static func calculateLeanBodyMass(person: ProfileInputViewModel, logger: AuditLogger) -> Double {
        let weight = Double(person.weight)
        let height = Double(person.height)
        
        switch person.bodyFatPercentageMethod {
        case .manualEntry:
            let bodyFat = Double(person.bodyFatPercentage) / 100.0
            let lbm = weight * (1 - bodyFat)
            
            //            logger.log(AuditItem(subTitle: "Manual Body Fat"))
            //            logger.log(AuditItem(formula: "lbm = weight * (1 - bodyFat%)"))
            
            return lbm
            
        case .estimate:
            let lbm: Double
            if person.gender == .male {
                lbm = 0.407 * weight + 0.267 * height - 19.2
            } else {
                lbm = 0.252 * weight + 0.473 * height - 48.3
            }
            
            //            logger.log(AuditItem(subTitle: "Estimated Body Fat"))
            return lbm
            
        case .omit:
            return 0
        }
    }
    
    private  static func adjustForActivity(
        bmr: Double,
        activityLevel: enumActivityLevel,
        logger: AuditLogger
    ) -> Double {
        
        let result = bmr * activityLevel.KatchMcArdleMultipliers
        
        //        logger.log(AuditItem(subTitle: "Activity Adjustment"))
        //        logger.log(AuditItem(formula: "tdee = bmr * activity"))
        
        return result
    }
    
    static func adjustCalories(base: Double, person: ProfileInputViewModel, logger: AuditLogger) -> Double {
        //        switch person.calorieAdjustmentMethod {
        //        case .Maintain:
        return base
        //        case .Bulk:
        //            return base + Double(person.calorieAdjustment)
        //        case .Cut:
        //            return base - Double(person.calorieAdjustment)
        //        }
    }
    
    private  static func logMacros(calories: Double, person: ProfileInputViewModel, logger: AuditLogger) {
        //        logger.log(AuditItem(subTitle: "Macro Split"))
        
        //        let protein = (Double(person.protein) / 100.0) * calories / 4.0
        //        let carbs = (Double(person.carbs) / 100.0) * calories / 4.0
        //        let fats = (Double(person.fats) / 100.0) * calories / 9.0
        
        //        logger.log(AuditItem(key: "Protein", value: "\(Int(protein))g"))
        //        logger.log(AuditItem(key: "Carbs", value: "\(Int(carbs))g"))
        //        logger.log(AuditItem(key: "Fats", value: "\(Int(fats))g"))
    }
}


