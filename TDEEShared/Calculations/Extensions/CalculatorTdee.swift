//
//  CalculatorTdee.swift
//  TDEE
//
//  Created by David Berry on 30/06/2026.
//

import Foundation

extension Calculator {
    @discardableResult @MainActor static func calculateTdee(result: CalculatorResultViewModel, person: ProfileViewModel, createAudit: Bool = false) async -> Double {

        var logger = AuditLogger(enabled: createAudit)

        logger.log(AuditItem(title: "Total Daily Energy Expenditure"))
        logger.logInputs(person: person)

        // Calculate BMR
        let bmr: Double
        switch person.bodyFatPercentageMethod {
        case .omit:
            bmr = person.calculateMifflinStJeor( logger: logger)
        case .estimate, .manualEntry:
            bmr = person.calculateKatchMcArdle( logger: logger)
        }

        // Adjust for activity
        let tdee = adjustForActivityLevel(bmr: bmr, activityLevel: person.activityLevel, logger: logger)

        // Adjust calories
        let adjustedCalories = person.adjustCalories(base: tdee,  logger: logger)

        result.updateTdee(
            bmr: bmr,
            tdee: tdee,
            adjustedCalories: adjustedCalories
        )

        return tdee
    }



    public static func adjustForActivityLevel(
       bmr: Double,
       activityLevel: ActivityLevel,
       logger: AuditLogger
   ) -> Double {

       let result = bmr * activityLevel.KatchMcArdleMultipliers
       return result
   }


}
