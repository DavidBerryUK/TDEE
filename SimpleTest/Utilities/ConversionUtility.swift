//
//  ConversionService.swift
//  TDEEv4
//
//  Created by David Berry on 06/08/2020.
//  Copyright © 2020 David Berry. All rights reserved.
//

import Foundation
//
//class ConversionUtility {
//    
//    //*******************************************************
//    // Weight Conversions                                   *
//    // weights are always stored in kg as a double          *
//    // but can be displayed to the user in                  *
//    // 1) Kg,  2) Pounds 3) Stones & Pounds                 *
//    //*******************************************************
//    static func ToPoundsInt( kilograms : Double) -> Int {
//        let pounds = Float(kilograms) * 2.20462262185
//        return Int(round(pounds))
//    }
//    
//    static func ToStonesOnlyInt( kilograms : Double) -> Int {
//        let pounds = Int(round(Double(kilograms) * 2.20462262185))
//        return Int (pounds / 14 );
//    }
//    
//    static func ToPoundsOnlyInt( kilograms : Double) -> Int {
//        let pounds = Int(round(Double(kilograms) * 2.20462262185))
//        return Int (pounds % 14 );
//    }
//    
//    static func ToPoundsInt( kilograms : Int) -> Int {
//        let pounds = Float(kilograms) * 2.20462262185
//        return Int(round(pounds))
//    }
//    
//    static func ToKilograms( pounds : Double) -> Double {
//        let kilograms = Double(pounds) * 0.45359237
//        return kilograms
//    }
//    
//    static func ToKilograms( pounds : Int) -> Double {
//        let kilograms = Double(pounds) * 0.45359237
//        return kilograms
//    }
//    
//    static func ToKilogramsInt( pounds : Int) -> Int {
//        let kilograms = Double(pounds) * 0.45359237
//        return Int(round(kilograms))
//    }
//    
//    static func ToKilograms( stones: Int , pounds : Int) -> Double {
//        let kilograms = Double(stones * 14 + pounds) * 0.45359237
//        return kilograms
//    }
//    
//    
//    
//    //*******************************************************
//    // Length Conversions                                   *
//    //*******************************************************
//    
//    static func ToInches( centimeters : Int) -> Int {
//        let inches = Float(centimeters) * 0.3937007874
//        return Int(round(inches))
//    }
//    
//    static func ToCentimeters( inches : Int) -> Int {
//        let centimeters = Float(inches) * 2.54
//        return Int(round(centimeters))
//    }
//    
//}


enum ConversionUtility {
    
    private static let poundsPerKg = 2.20462262185
    private static let kgPerPound = 0.45359237
    
    // MARK: - Weight
    
    //*******************************************************
    // Weight Conversions                                   *
    // weights are always stored in kg as a double          *
    // but can be displayed to the user in                  *
    // 1) Kg,  2) Pounds 3) Stones & Pounds                 *
    //*******************************************************
    
    static func toPounds(_ kilograms: Double) -> Int {
        Int(round(kilograms * poundsPerKg))
    }
    static func toPounds(_ kilograms: Int) -> Int {
        Int(round(Double(kilograms) * poundsPerKg))
    }
    
    
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
    
    static func toStones(_ kilograms: Double) -> Int {
        let totalPounds = toPounds(kilograms)
        return totalPounds / 14
    }
    
    static func toRemainingPounds(_ kilograms: Double) -> Int {
        let totalPounds = toPounds(kilograms)
        return totalPounds % 14
    }
    
    // MARK: - Length
    
    static func toInches(_ centimeters: Double) -> Int {
        Int(round(centimeters * 0.3937007874))
    }
    
    static func toInches(_ centimeters: Int) -> Int {
        Int(round(Double(centimeters) * 0.3937007874))
    }
    
    static func toCentimeters(_ inches: Double) -> Int {
        Int(round(inches * 2.54))
    }
    
    static func toCentimeters(_ inches: Int) -> Int {
        Int(round(Double(inches) * 2.54))
    }
}
