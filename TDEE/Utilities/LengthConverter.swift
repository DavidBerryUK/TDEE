//
//  convertHeight.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import Foundation

struct LengthConverter {

    /// Conversion factor from inches to centimeters (2.54)
    private static let inchesToCentimetersFactor = 2.54

    /// Conversion factor from centimeters to inches (0.3937007874)
    private static let centimetersToInchesFactor = 0.3937007874

    static func toCentimeters(inches: Double) -> Double {
        inches * inchesToCentimetersFactor
    }

    static func toCentimeters(feet: Int, inches: Int) -> Double {
        Double(12 * feet + inches) * inchesToCentimetersFactor
    }

    static func toCentimeters(_ inches: Int) -> Double {
        Double(inches) * inchesToCentimetersFactor
    }

    static func toCentimetersInt(_ inches: Int) -> Int {
        Int(floor(Double(inches) * inchesToCentimetersFactor))
    }

    static func toInches(_ centimeters: Double) -> Int {
        Int(round(centimeters * centimetersToInchesFactor))
    }

    static func toInches(_ centimeters: Int) -> Int {
        Int(round(Double(centimeters) * centimetersToInchesFactor))
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
