//
//  AuditLogger.swift
//  TDEE
//
//  Created by David Berry on 06/04/2026.
//

import Foundation
import SwiftUI

/// Logs calculation steps for audit purposes.
///
/// Used to track the calculation process and create a traceable history
/// of how values were derived.
struct AuditLogger {

    /// Whether logging is enabled
    let enabled: Bool
    private(set) var items: [AuditItem] = []

    /// Adds an item to the audit log.
    /// - Parameter item: The audit item to log
    mutating func log(_ item: AuditItem) {
        guard enabled else { return }
        items.append(item)
    }

    /// Logs the input values from a profile.
    /// - Parameter person: The profile to log inputs from
    @MainActor
    mutating func logInputs(person: ProfileViewModel) {
        guard enabled else { return }

        items.append(AuditItem(subTitle: "Inputs"))
        items.append(AuditItem(key: "Age", value: "\(person.age)"))
        items.append(AuditItem(key: "Height", value: "\(person.height)"))
        items.append(AuditItem(key: "Weight", value: "\(person.weight)"))
    }

    /// Logs a formula and its calculation.
    /// - Parameters:
    ///   - title: The formula title
    ///   - formula: The formula string
    ///   - calculation: The actual calculation values
    mutating func logFormula(title: String, formula: String, calculation: String) {
        guard enabled else { return }

        items.append(AuditItem(formulaTitle: title))
        items.append(AuditItem(formula: formula))
        items.append(AuditItem(formula: calculation))
    }
}
