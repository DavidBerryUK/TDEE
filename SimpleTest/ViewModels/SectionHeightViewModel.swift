import Foundation
import Combine
//
//  SectionB.swift
//  SimpleTest
//
//  Created by David Berry on 01/04/2026.
//


final class SectionHeightViewModel: SectionViewModelIdentifiable {
    let id = UUID()
    @Published var isExpanded: Bool
    let title: String
    let summary: String
    let details: String
    
    // custom properties
    let height: Int

    init(title: String = "Section B", summary: String = "Overview for B", details: String = "Detailed information for Section B goes here.", isExpanded: Bool = false) {
        self.title = title
        self.summary = summary
        self.details = details
        self.isExpanded = isExpanded
        
        // custom properties
        self.height = 20
    }
}
