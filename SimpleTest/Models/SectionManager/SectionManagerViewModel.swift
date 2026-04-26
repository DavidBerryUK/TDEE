//
//  SectionManagerViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 26/04/2026.
//

import Foundation
import Combine
import Observation

@Observable
final class SectionManagerViewModel: ObservableObject {
    
    // custom properties
    internal var isUpdatingExpansion = false
    
    var genderIsExpanded: Bool
    {
        didSet {
            enforceExclusiveExpansion(changed: .gender, newValue: genderIsExpanded)
        }
    }
    
    var ageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .age, newValue: ageIsExpanded)
        }
    }
    
    var weightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .weight, newValue: weightIsExpanded)
        }
    }
    
    var heightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .height, newValue: heightIsExpanded)
        }
    }
    
    var activityLevelIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .activityLevel, newValue: activityLevelIsExpanded)
        }
    }
    
    var bodyFatPercentageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .bodyFatPercentage, newValue: bodyFatPercentageIsExpanded)
        }
    }
    
    var calorieAdjustmentExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .calorieAdjustmentMethod, newValue: calorieAdjustmentExpanded)
        }
    }
    
    var macroMixExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .macroMix, newValue: macroMixExpanded)
        }
    }
    
    
    //*******************************
    // Initialiser                  *
    //*******************************
    init() {
        // Initialize expansion flags without triggering observers
        self.isUpdatingExpansion = true
        
        self.ageIsExpanded = false
        self.genderIsExpanded = false
        self.weightIsExpanded = false
        self.heightIsExpanded = false
        self.activityLevelIsExpanded = false
        self.bodyFatPercentageIsExpanded = false
        self.calorieAdjustmentExpanded = false
        self.macroMixExpanded = false
        
        self.isUpdatingExpansion = false
    }
    
    //
    // Enforce only 1 section being expanded
    //
    internal func enforceExclusiveExpansion(changed: enumSection, newValue: Bool) {
        if isUpdatingExpansion { return }
        guard newValue == true else { return }
        isUpdatingExpansion = true
        
        if ( changed != .age && ageIsExpanded)
        {
            ageIsExpanded = false
        }
        if ( changed != .gender && genderIsExpanded)
        {
            genderIsExpanded = false
        }
        if ( changed != .height && heightIsExpanded)
        {
            heightIsExpanded = false
        }
        if ( changed != .weight && weightIsExpanded)
        {
            weightIsExpanded = false
        }
        if ( changed != .bodyFatPercentage && bodyFatPercentageIsExpanded)
        {
            bodyFatPercentageIsExpanded = false
        }
        if ( changed != .activityLevel && activityLevelIsExpanded)
        {
            activityLevelIsExpanded = false
        }
        if ( changed != .calorieAdjustmentMethod && calorieAdjustmentExpanded)
        {
            calorieAdjustmentExpanded = false
        }
        if ( changed != .macroMix && macroMixExpanded)
        {
            macroMixExpanded = false
        }
        
        isUpdatingExpansion = false
    }
    
    public func collapseAll() {
        enforceExclusiveExpansion(changed: .none, newValue: true)
    }
}
