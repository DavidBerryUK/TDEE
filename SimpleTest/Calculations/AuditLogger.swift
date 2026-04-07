////
////  AuditLogger.swift
////  SimpleTest
////
////  Created by David Berry on 06/04/2026.
////
//struct AuditLogger {
//    
//    let enabled: Bool
//    private(set) var items: [AuditItem] = []
//    
//    mutating func log(_ item: AuditItem) {
//        guard enabled else { return }
//        items.append(item)
//    }
//    
//    mutating func logInputs(person: ProfileInputViewModel) {
//        guard enabled else { return }
//        
//        items.append(AuditItem(subTitle: "Inputs"))
//        items.append(AuditItem(key: "Age", value: "\(person.age)"))
//        items.append(AuditItem(key: "Height", value: "\(person.height)"))
//        items.append(AuditItem(key: "Weight", value: "\(person.weight)"))
//    }
//    
//    mutating func logFormula(title: String, formula: String, calculation: String) {
//        guard enabled else { return }
//        
//        items.append(AuditItem(formulaTitle: title))
//        items.append(AuditItem(formula: formula))
//        items.append(AuditItem(formula: calculation))
//    }
//}
