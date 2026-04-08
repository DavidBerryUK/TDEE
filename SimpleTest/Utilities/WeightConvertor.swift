//
//  ConversionService.swift
//  TDEEv4
//
//  Created by David Berry on 06/08/2020.
//  Copyright © 2020 David Berry. All rights reserved.
//

import Foundation

struct WeightConvertor {
    
    private static let poundsPerKg = 2.20462262185
    private static let kgPerPound = 0.45359237
    
    // MARK: - Weight
    
    //*******************************************************
    // Weight Conversions                                   *
    // weights are always stored in kg as a double          *
    // but can be displayed to the user in                  *
    // 1) Kg,  2) Pounds 3) Stones & Pounds                 *
    //*******************************************************
    
    static func toKilograms( pounds: Double) -> Double {
        pounds * kgPerPound
    }
    
    static func toKilograms( pounds: Int) -> Double {
        Double(pounds) * kgPerPound
    }
    
    static func toKilogramsInt( pounds: Int) -> Int {
        Int(round(  Double(pounds) * kgPerPound))
    }
    
    static func toKilograms(stones: Int, pounds: Int) -> Double {
        Double(stones * 14 + pounds) * kgPerPound
    }
    
    static func toPounds(_ kilograms: Double) -> Int {
        Int(floor(kilograms * poundsPerKg))
    }
    
    static func toPounds(_ kilograms: Int) -> Int {
        Int(floor(Double(kilograms) * poundsPerKg))
    }
    
    static func toStones(_ kilograms: Double) -> Int {
        let totalPounds = toPounds(kilograms)
        return totalPounds / 14
    }
    
    static func toRemainingPounds(_ kilograms: Double) -> Int {
        let totalPounds = toPounds(kilograms)
        return totalPounds % 14
    }
}
