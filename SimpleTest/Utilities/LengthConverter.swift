//
//  convertHeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import Foundation

enum LengthConverter {
    
    static func toCentimeters(inches: Double) -> Double {
        inches * 2.54
    }
    
    static func toCentimeters(feet: Int, inches: Int) -> Double {
        Double(12 * feet + inches) * 2.54
    }
    
    static func toCentimeters(_ inches: Int) -> Double {
        Double(inches) * 2.54
    }
    
    static func toCentimetersInt(_ inches: Int) -> Int {
        Int(floor(Double(inches) * 2.54))
    }
    
    static func toInches(_ centimeters: Double) -> Int {
        Int(round(centimeters * 0.3937007874))
    }
    
    static func toInches(_ centimeters: Int) -> Int {
        Int(round(Double(centimeters) * 0.3937007874))
    }
  
    static func toFeet(_ centimeters: Double) -> Int {
        let totalInches = toInches(centimeters)
        return totalInches / 12
    }
    
    static func toRemainingInches(_ centimeters: Double) -> Int {
        let totalInches = toInches(centimeters)
        return totalInches % 12
    }
}
