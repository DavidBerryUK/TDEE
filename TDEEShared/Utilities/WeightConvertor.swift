//
//  ConversionService.swift
//  TDEEv4
//
//  Created by David Berry on 06/08/2020.
//  Copyright © 2020 David Berry. All rights reserved.
//

import Foundation

struct WeightConvertor {

    /// Conversion factor from kilograms to pounds (2.20462262185)
    private static let poundsPerKg = 2.20462262185

    /// Conversion factor from pounds to kilograms (0.45359237)
    private static let kgPerPound = 0.45359237
    
    // MARK: - Weight
    
    //*******************************************************
    // Weight Conversions                                   *
    // weights are always stored in kg as a double          *
    // but can be displayed to the user in                  *
    // 1) Kg,  2) Pounds 3) Stones & Pounds                 *
    //*******************************************************
    
    static func toKilograms( pounds: Double) -> Double {
        let result =  pounds * kgPerPound
        return result
    }
    
    static func toKilograms( pounds: Int) -> Double {
        let result = Double(pounds) * kgPerPound
        return result
    }
    
    static func toKilogramsInt( pounds: Int) -> Int {
        return Int(floor(  Double(pounds) * kgPerPound))
    }
    
    static func toKilograms(stones: Int, pounds: Int) -> Double {
        return Double(stones * 14 + pounds) * kgPerPound
    }
    
    static func toPounds(_ kilograms: Double) -> Int {
        let result = Int(floor(kilograms * poundsPerKg))
        return result
    }
    
    static func toPounds(_ kilograms: Int) -> Int {
        let result = Int(floor(Double(kilograms) * poundsPerKg))
        return result
    }
    
    static func toStones(_ kilograms: Double) -> Int {
        let totalPounds = toPounds(kilograms)
        return totalPounds / 14
    }
    
    static func toRemainingPounds(_ kilograms: Double) -> Int {
        let totalPounds = toPounds(kilograms)
        let result = totalPounds % 14
        return result
    }
}
