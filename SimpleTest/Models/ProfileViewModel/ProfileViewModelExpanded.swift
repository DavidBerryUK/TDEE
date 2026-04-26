//
//  ProfileViewModelExpanded.swift
//  SimpleTest
//
//  Created by David Berry on 15/04/2026.
//

extension ProfileViewModel {
    //
    // Enforce only 1 section being expanded
    //
    internal func enforceExclusiveExpansion(changed: enumSection, newValue: Bool) {
        if isUpdatingExpansion { return }
        guard newValue == true else { return }
        isUpdatingExpansion = true
        
        if ( changed != .age && ageIsExpanded) { ageIsExpanded = false }
        if ( changed != .gender && genderIsExpanded) { genderIsExpanded = false }
        if ( changed != .height && heightIsExpanded) { heightIsExpanded = false }
        if ( changed != .weight && weightIsExpanded) { weightIsExpanded = false }
        if ( changed != .bodyFatPercentage && bodyFatPercentageIsExpanded) { bodyFatPercentageIsExpanded = false }
        if ( changed != .activityLevel && activityLevelIsExpanded) { activityLevelIsExpanded = false }
        if ( changed != .calorieAdjustmentMethod && calorieAdjustmentExpanded) { calorieAdjustmentExpanded = false }
        
        isUpdatingExpansion = false
    }
    
    public func collapseAll() {
        enforceExclusiveExpansion(changed: .none, newValue: true)
    }
}
