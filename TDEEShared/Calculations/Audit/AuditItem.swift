//
//  AuditItem.swift
//  TDEE
//
//  Created by David Berry on 06/04/2026.
//

import Foundation

import Foundation

/// Represents a single item in an audit log.
///
/// Used to track calculation steps and create a traceable history
/// of how values were derived.
struct AuditItem: Identifiable {

    // MARK: - Types

    /// The type of audit item
    enum ItemType {
        case title          /// Section title
        case subTitle       /// Section subtitle
        case keyValue       /// Key-value pair
        case formulaTitle   /// Formula title
        case formula        /// Formula expression
        case message        /// Message text
        case divider        /// Visual divider
    }

    // MARK: - Properties

    /// Unique identifier for this item
    let id = UUID()
    /// The type of this audit item
    let type: ItemType

    /// The main title text
    let title: String?
    /// The key for key-value items
    let key: String?
    /// The value for key-value items
    let value: String?
    /// The formula string
    let formula: String?
    /// The message text
    let message: String?

    // MARK: - Initialisers

    /// Creates a title item.
    /// - Parameter title: The title text
    init(title: String) {
        self.type = .title
        self.title = title
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }

    /// Creates a subtitle item.
    /// - Parameter subTitle: The subtitle text
    init(subTitle: String) {
        self.type = .subTitle
        self.title = subTitle
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }

    /// Creates a key-value pair item.
    /// - Parameters:
    ///   - key: The key name
    ///   - value: The value string
    init(key: String, value: String) {
        self.type = .keyValue
        self.title = nil
        self.key = key
        self.value = value
        self.formula = nil
        self.message = nil
    }

    /// Creates a formula title item.
    /// - Parameter formulaTitle: The formula title
    init(formulaTitle: String) {
        self.type = .formulaTitle
        self.title = formulaTitle
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }

    /// Creates a formula expression item.
    /// - Parameter formula: The formula string
    init(formula: String) {
        self.type = .formula
        self.title = nil
        self.key = nil
        self.value = nil
        self.formula = formula
        self.message = nil
    }

    /// Creates a message item.
    /// - Parameter message: The message text
    init(message: String) {
        self.type = .message
        self.title = nil
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = message
    }

    /// Creates a divider item.
    /// - Parameter divider: Boolean (unused, retained for API compatibility)
    init(divider: Bool) {
        self.type = .divider
        self.title = nil
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }
}
