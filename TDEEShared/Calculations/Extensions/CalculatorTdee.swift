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

        // Calculate BMR.
        //
        // Age matters only in the `.omit` path: Mifflin-St Jeor carries a `- 5.0 * age` term.
        // Katch-McArdle (`.estimate` / `.manualEntry`) is `370 + 21.6 * LBM`, and both LBM routes
        // (Bergström estimate, manual body-fat entry) are age-free too — so the canonical formula
        // legitimately ignores age there. That is by design, not a bug: the Age input is inert
        // under Estimate / Manual Entry, and the UI keeps it active on purpose (user decision,
        // 2026-10-22). Don't "restore" age here without changing the formula itself.
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
