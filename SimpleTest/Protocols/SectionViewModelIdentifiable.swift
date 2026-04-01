import Foundation
import Combine
//
//  SectionIdentifiable.swift
//  SimpleTest
//
//  Created by David Berry on 01/04/2026.
//


protocol SectionViewModelIdentifiable: ObservableObject, Identifiable {
    var id: UUID { get }
    var title: String { get }
    var summary: String { get }
    var details: String { get }
    var isExpanded: Bool { get set }
}
