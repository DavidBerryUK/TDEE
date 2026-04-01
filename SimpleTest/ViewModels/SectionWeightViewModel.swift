//
//  SectionWeight.swift
//  SimpleTest
//
//  Created by David Berry on 01/04/2026.
//


import Foundation
import Combine

final class SectionWeightViewModel: SectionViewModelIdentifiable {
    let id = UUID()
    @Published var isExpanded: Bool
    let title: String
    let summary: String
    let details: String
    
    // custom properties
    let weight: Int

    init(title: String = "Weight", summary: String = "Overview for D", details: String = "Detailed information for Section D goes here.", isExpanded: Bool = false) {
        self.title = title
        self.summary = summary
        self.details = details
        self.isExpanded = isExpanded
        
        // custom properties
        self.weight = 100
    }
}
