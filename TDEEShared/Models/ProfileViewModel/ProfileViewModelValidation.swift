//
//  ProfileViewModelValidation.swift
//  TDEE
//
//  Created by David Berry on 15/04/2026.
//

extension ProfileViewModel {
    //*******************************
    // Computed Properties          */
    //*******************************
    /// Whether any required field is missing or invalid
    var hasError: Bool {
        !isAgeValid || !isWeightValid || !isHeightValid
    }

    /// Whether all required fields are valid
    var isValid: Bool {
        isAgeValid && isWeightValid && isHeightValid
    }

    /// Whether weight is within the accepted range (story 023, input #4, Decision 15). An out-of-range
    /// or zero weight hides the results, not just a zero — the New text entry only commits in-range
    /// values, so this mainly guards a profile loaded with a bad weight. Mirrors `isAgeValid` and is
    /// kept in sync with `validateForCalculation()` (Decision 14).
    var isWeightValid: Bool {
        MetricRanges.weight.contains(weight)
    }

    /// Whether height is valid (non-zero)
    var isHeightValid: Bool {
        height != 0
    }

    /// Whether age is within the accepted range (story 023, input #2). An empty or out-of-range age
    /// hides the results, not just a zero — the New text input only commits in-range values, so this
    /// mainly guards a profile loaded with a bad age.
    var isAgeValid: Bool {
        MetricRanges.age.contains(age)
    }
}
