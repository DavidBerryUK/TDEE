//
//  ProfileViewModelValidation.swift
//  SimpleTest
//
//  Created by David Berry on 15/04/2026.
//

extension ProfileViewModel {
    //*******************************
    // Computed Properties          */
    //*******************************
    /// Whether any required field is missing or invalid
    var hasError: Bool {
        age == 0 || weight == 0 || height == 0
    }

    /// Whether all required fields are valid
    var isValid: Bool {
        age != 0 && weight != 0 && height != 0
    }

    /// Whether weight is valid (non-zero)
    var isWeightValid: Bool {
        weight != 0
    }

    /// Whether height is valid (non-zero)
    var isHeightValid: Bool {
        height != 0
    }

    /// Whether age is valid (non-zero)
    var isAgeValid: Bool {
        age != 0
    }
}
