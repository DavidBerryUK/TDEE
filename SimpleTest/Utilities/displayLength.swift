//
//  DisplayLength.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//
import Foundation

struct DisplayLength {

    static func asCentimeters(cm : Double) -> Int {
        return Int(round(cm))
    }
    
    static func asInches(cm : Double) -> Int {
        return LengthConverter.toInches(cm)
    }
    
    static func asFeet(cm : Double) -> Int {
        return LengthConverter.toFeet(cm)
    }
    
    static func asInchesRemaining(cm : Double) -> Int {
        return LengthConverter.toRemainingInches(cm)
    }
    
    static func asMajorValue(length : Double, unit: OptionLength) -> String {
        switch unit {
        case .centimeters:
            return "\(asCentimeters( cm: length))"
        case .inches:
            return "\(asInches(cm: length))"
        case .feetAndInches:
            return "\(asFeet(cm: length))"
        }
    }
    
    static func asMinorValue(length : Double, unit: OptionLength) -> String {
        switch unit {
        case .centimeters:
            return ""
        case .inches:
            return ""
        case .feetAndInches:
            return "\(asInchesRemaining(cm: length))"
        }
    }
}
