import Foundation
import Combine
//
//  SectionAge.swift
//  SimpleTest
//
//  Created by David Berry on 01/04/2026.
//


final class SectionAgeViewModel: SectionViewModelIdentifiable {
    let id = UUID()
    @Published var isExpanded: Bool
    let title: String
    let summary: String
    let details: String
    
    // custom properties
    let age: Int

    init(title: String = "Section A", summary: String = "Overview for A", details: String = "Detailed information for Section A goes here.", isExpanded: Bool = false) {
        self.title = title
        self.summary = summary
        self.details = details
        self.isExpanded = isExpanded
        
        // custom properties
        self.age  = 21
    }
}
