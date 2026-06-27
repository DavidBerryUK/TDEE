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
    var hasError: Bool {
        weight == 0 || height == 0
    }
    
    var isValid: Bool {
        weight != 0 && height != 0
    }
    
    var isWeightValid: Bool {
        weight != 0
    }
    
    var isHeightValid: Bool {
        height != 0
    }
}
