//
//  DisplayFormat.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//
import Foundation

class DisplayFormat {

    static func WeightAsKg(kilograms : Double) -> Int {
        return Int(round(kilograms))
    }
    
    static func WeightAsPounds(kilograms : Double) -> Int {
        return ConversionUtility.toPounds(kilograms)
    }
    
    static func WeightAsStonesOnly(kilograms : Double) -> Int {
        return ConversionUtility.toStones(kilograms)
    }
    
    static func WeightAsPoundsOnly(kilograms : Double) -> Int {
        return ConversionUtility.toRemainingPounds(kilograms)
    }
}
