//
//  DisplayWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//
import Foundation

struct DisplayWeight {

    static func asKg(kilograms : Double) -> Int {
        return Int(round(kilograms))
    }
    
    static func asPounds(kilograms : Double) -> Int {
        return WeightConvertor.toPounds(kilograms)
    }
    
    static func asStones(kilograms : Double) -> Int {
        return WeightConvertor.toStones(kilograms)
    }
    
    static func asPoundsRemaining(kilograms : Double) -> Int {
        return WeightConvertor.toRemainingPounds(kilograms)
    }
    
    static func asMajorValue(weight : Double, unit: OptionWeight) -> String {
        switch unit {
        case .kilograms:
            return "\(DisplayWeight.asKg(kilograms: weight))"
        case .pounds:
            return "\(DisplayWeight.asPounds(kilograms: weight))"
        case .stonesAndPounds:
            return "\(DisplayWeight.asStones(kilograms: weight))"
        }
    }
    
    static func asMinorValue(weight : Double, unit: OptionWeight) -> String {
        switch unit {
        case .kilograms:
            return ""
        case .pounds:
            return ""
        case .stonesAndPounds:
            return "\(DisplayWeight.asPoundsRemaining(kilograms: weight))"
        }
    }
}
