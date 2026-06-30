//
//  AuditItem.swift
//  SimpleTest
//
//  Created by David Berry on 06/04/2026.
//

import Foundation

struct AuditItem: Identifiable {
    
    // MARK: - Types
    
    enum ItemType {
        case title
        case subTitle
        case keyValue
        case formulaTitle
        case formula
        case message
        case divider
    }
    
    // MARK: - Properties
    
    let id = UUID()
    let type: ItemType
    
    let title: String?
    let key: String?
    let value: String?
    let formula: String?
    let message: String?
    
    // MARK: - Initialisers
    
    init(title: String) {
        self.type = .title
        self.title = title
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }
    
    init(subTitle: String) {
        self.type = .subTitle
        self.title = subTitle
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }
    
    init(key: String, value: String) {
        self.type = .keyValue
        self.title = nil
        self.key = key
        self.value = value
        self.formula = nil
        self.message = nil
    }
    
    init(formulaTitle: String) {
        self.type = .formulaTitle
        self.title = formulaTitle
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }
    
    init(formula: String) {
        self.type = .formula
        self.title = nil
        self.key = nil
        self.value = nil
        self.formula = formula
        self.message = nil
    }
    
    init(message: String) {
        self.type = .message
        self.title = nil
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = message
    }
    
    init(divider: Bool) {
        self.type = .divider
        self.title = nil
        self.key = nil
        self.value = nil
        self.formula = nil
        self.message = nil
    }
}
