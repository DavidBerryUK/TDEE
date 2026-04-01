import Foundation
import Combine

//
//  SectionActivityLevel.swift
//  SimpleTest
//
//  Created by David Berry on 01/04/2026.
//


final class SectionActivityLevelViewModel: SectionViewModelIdentifiable {
    let id = UUID()
    @Published var isExpanded: Bool
    let title: String
    let summary: String
    let details: String
    
    // custom properties
    let activityLevel : Int;

    init(title: String = "Section C", summary: String = "Overview for C", details: String = "Detailed information for Section C goes here.", isExpanded: Bool = false) {
        self.title = title
        self.summary = summary
        self.details = details
        self.isExpanded = isExpanded
        
        // custom properties
        self.activityLevel = 1
    }
}
