import Foundation
import Combine
//
//  SectionBodyFat.swift
//  SimpleTest
//
//  Created by David Berry on 01/04/2026.
//


import Foundation
import Combine

final class SectionBodyFatViewModel: SectionViewModelIdentifiable {
    let id = UUID()
    @Published var isExpanded: Bool
    let title: String
    let summary: String
    let details: String
    
    // custom properties
    let bodyFatPercentage : Int

    init(title: String = "Fat Percentage", summary: String = "Overview for E", details: String = "Detailed information for Section E goes here.", isExpanded: Bool = false) {
        self.title = title
        self.summary = summary
        self.details = details
        self.isExpanded = isExpanded
    
        // custom properties
        self.bodyFatPercentage  = 15
    }
}
