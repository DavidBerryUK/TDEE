//
//  SectionManagerViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 26/04/2026.
//

import Foundation
import Observation

/// Manages the expansion state of sections in the UI.
///
/// Ensures only one section is expanded at a time through exclusive expansion logic.
@Observable
final class SectionManagerViewModel {

    // custom properties
    /// Whether expansion updates are in progress (prevents recursion)
    internal var isUpdatingExpansion = false

    /// Whether the gender section is expanded
    var genderIsExpanded: Bool
    {
        didSet {
            enforceExclusiveExpansion(changed: .gender, newValue: genderIsExpanded)
        }
    }

    /// Whether the age section is expanded
    var ageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .age, newValue: ageIsExpanded)
        }
    }

    /// Whether the weight section is expanded
    var weightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .weight, newValue: weightIsExpanded)
        }
    }

    /// Whether the height section is expanded
    var heightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .height, newValue: heightIsExpanded)
        }
    }

    /// Whether the activity level section is expanded
    var activityLevelIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .activityLevel, newValue: activityLevelIsExpanded)
        }
    }

    /// Whether the body fat percentage section is expanded
    var bodyFatPercentageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .bodyFatPercentage, newValue: bodyFatPercentageIsExpanded)
        }
    }

    /// Whether the calorie adjustment section is expanded
    var calorieAdjustmentExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .calorieAdjustmentMethod, newValue: calorieAdjustmentExpanded)
        }
    }

    /// Whether the macro mix section is expanded
    var macroMixExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .macroMix, newValue: macroMixExpanded)
        }
    }


    //*******************************
    // Initialiser                  *
    //*******************************
    /// Creates a new SectionManagerViewModel with all sections collapsed
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
    /// Collapses all sections except the one that was just expanded.
    /// - Parameters:
    ///   - changed: The section that changed state
    ///   - newValue: The new expansion state (should be true to trigger logic)
    internal func enforceExclusiveExpansion(changed: Section, newValue: Bool) {
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

    /// Collapses all sections.
    public func collapseAll() {
        enforceExclusiveExpansion(changed: .none, newValue: true)
    }
}
