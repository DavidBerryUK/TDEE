//
//  TdeeResult.swift
//  SimpleTest
//
//  Created by David Berry on 25/04/2026.
//

import Foundation
import Combine
import Observation

@Observable
final class TdeeResultViewModel : ObservableObject {
    var bmr: Double
    var tdee: Double
    var adjustedCalories: Double
    var message: String?
    var audit: [AuditItem]

    init(bmr: Double = 0,
         tdee: Double = 0,
         adjustedCalories: Double = 0,
         message: String? = nil,
         audit: [AuditItem] = []) {
        self.bmr = bmr
        self.tdee = tdee
        self.adjustedCalories = adjustedCalories
        self.message = message
        self.audit = audit
    }
}
