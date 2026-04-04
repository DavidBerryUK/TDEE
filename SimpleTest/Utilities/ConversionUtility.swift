//
//  ConversionService.swift
//  TDEEv4
//
//  Created by David Berry on 06/08/2020.
//  Copyright © 2020 David Berry. All rights reserved.
//

import Foundation

class ConversionUtility {
    
    static func ToPounds( kilograms : Int) -> Int {
        let pounds = Float(kilograms) * 2.20462262185
        return Int(round(pounds))
    }
    
    static func ToKilograms( pounds : Int) -> Int {
        let kilograms = Float(pounds) * 0.45359237
        return Int(round(kilograms))
    }
    
    static func ToInches( centimeters : Int) -> Int {
        let inches = Float(centimeters) * 0.3937007874
        return Int(round(inches))
    }
    
    static func ToCentimeters( inches : Int) -> Int {
        let centimeters = Float(inches) * 2.54
        return Int(round(centimeters))
    }
    
    static func Convert(value: Int, from: enumOptionLength, to :enumOptionLength) -> Int {
        switch from {
        case .inches, .feetAndInches:
            if ( to == .centimeters ) {
                return ToCentimeters(inches: value)
            }
            return value
        case .centimeters:
            if ( to == .inches || to == .feetAndInches ) {
                return ToInches(centimeters: value)
            }
            return value
        }
    }
    
    static func Convert(value: Int, from: enumOptionWeight, to : enumOptionWeight) -> Int {
        switch from {
        case .pounds, .stonesAndPounds:
            if ( to == .kilograms ) {
                return ToKilograms(pounds: value)
            }
            return value
        case .kilograms:
            if ( to == .pounds || to == .stonesAndPounds ) {
                return ToPounds(kilograms: value)
            }
            return value
        }
    }
}
