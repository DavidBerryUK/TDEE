//
//  SectionManagerViewModel.swift
//  TDEE
//
//  Created by David Berry on 26/04/2026.
//

import Foundation
import Observation

/// Manages the expansion state of sections in the UI.
///
/// Ensures only one section is expanded at a time through exclusive expansion logic.
/// Simplified to use a single `expandedSection` property instead of individual booleans.
@Observable
final class SectionManagerViewModel {

    /// The currently expanded section, or nil if all sections are collapsed
    private(set) var expandedSection: Section?

    // MARK: - Computed properties for backwards compatibility

    /// Whether the gender section is expanded
    var genderIsExpanded: Bool {
        get { expandedSection == .gender }
        set {
            if newValue { expandedSection = .gender }
            else if expandedSection == .gender { expandedSection = nil }
        }
    }

    /// Whether the age section is expanded
    var ageIsExpanded: Bool {
        get { expandedSection == .age }
        set {
            if newValue { expandedSection = .age }
            else if expandedSection == .age { expandedSection = nil }
        }
    }

    /// Whether the weight section is expanded
    var weightIsExpanded: Bool {
        get { expandedSection == .weight }
        set {
            if newValue { expandedSection = .weight }
            else if expandedSection == .weight { expandedSection = nil }
        }
    }

    /// Whether the height section is expanded
    var heightIsExpanded: Bool {
        get { expandedSection == .height }
        set {
            if newValue { expandedSection = .height }
            else if expandedSection == .height { expandedSection = nil }
        }
    }

    /// Whether the activity level section is expanded
    var activityLevelIsExpanded: Bool {
        get { expandedSection == .activityLevel }
        set {
            if newValue { expandedSection = .activityLevel }
            else if expandedSection == .activityLevel { expandedSection = nil }
        }
    }

    /// Whether the body fat percentage section is expanded
    var bodyFatPercentageIsExpanded: Bool {
        get { expandedSection == .bodyFatPercentage }
        set {
            if newValue { expandedSection = .bodyFatPercentage }
            else if expandedSection == .bodyFatPercentage { expandedSection = nil }
        }
    }

    /// Whether the calorie adjustment section is expanded
    var calorieAdjustmentExpanded: Bool {
        get { expandedSection == .calorieAdjustmentMethod }
        set {
            if newValue { expandedSection = .calorieAdjustmentMethod }
            else if expandedSection == .calorieAdjustmentMethod { expandedSection = nil }
        }
    }

    /// Whether the macro mix section is expanded
    var macroMixExpanded: Bool {
        get { expandedSection == .macroMix }
        set {
            if newValue { expandedSection = .macroMix }
            else if expandedSection == .macroMix { expandedSection = nil }
        }
    }

    // MARK: - Initialization

    /// Creates a new SectionManagerViewModel with all sections collapsed
    init() {
        self.expandedSection = nil
    }

    // MARK: - Public methods

    /// Collapses all sections.
    func collapseAll() {
        expandedSection = nil
    }
}
