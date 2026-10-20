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
        !isAgeValid || !isWeightValid || !isHeightValid || !isBodyFatValid
    }

    /// Whether all required fields are valid
    var isValid: Bool {
        isAgeValid && isWeightValid && isHeightValid && isBodyFatValid
    }

    /// Whether the body fat percentage is valid (story 023, input #7, Decision 21). **Method-gated**:
    /// the 5–50% range applies only under `.manualEntry`. Omit / Estimate carry no % value to validate
    /// (their default `0.0` is out of range), so they always pass — without the guard every
    /// Omit / Estimate profile would read as invalid. Kept in sync with `validateForCalculation()`
    /// (Decision 14 analog), which also gates on `.manualEntry`.
    var isBodyFatValid: Bool {
        guard bodyFatPercentageMethod == .manualEntry else { return true }
        return MetricRanges.bodyFatPercentage.contains(bodyFatPercentage)
    }

    /// Whether weight is within the accepted range (story 023, input #4, Decision 15). An out-of-range
    /// or zero weight hides the results, not just a zero — the New text entry only commits in-range
    /// values, so this mainly guards a profile loaded with a bad weight. Mirrors `isAgeValid` and is
    /// kept in sync with `validateForCalculation()` (Decision 14).
    var isWeightValid: Bool {
        MetricRanges.weight.contains(weight)
    }

    /// Whether height is within the accepted range (story 023, input #6, Decision 14 analog). An
    /// out-of-range or zero height hides the results, not just a zero — the New text entry only
    /// commits in-range values, so this mainly guards a profile loaded with a bad height. Mirrors
    /// `isWeightValid` and is kept in sync with `validateForCalculation()`.
    var isHeightValid: Bool {
        MetricRanges.height.contains(height)
    }

    /// Whether age is within the accepted range (story 023, input #2). An empty or out-of-range age
    /// hides the results, not just a zero — the New text input only commits in-range values, so this
    /// mainly guards a profile loaded with a bad age.
    var isAgeValid: Bool {
        MetricRanges.age.contains(age)
    }
}
