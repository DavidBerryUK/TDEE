//
//  DisplayFormat.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//
import Foundation

struct displayWeight {

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
    
    static func asMajorValue(weight : Double, unit: enumOptionWeight) -> String {
        switch unit {
        case .kilograms:
            return "\(displayWeight.asKg(kilograms: weight))"
        case .pounds:
            return "\(displayWeight.asPounds(kilograms: weight))"
        case .stonesAndPounds:
            return "\(displayWeight.asStones(kilograms: weight))"
        }
    }
    
    static func asMinorValue(weight : Double, unit: enumOptionWeight) -> String {
        switch unit {
        case .kilograms:
            return ""
        case .pounds:
            return ""
        case .stonesAndPounds:
            return "\(displayWeight.asPoundsRemaining(kilograms: weight))"
        }
    }
}
