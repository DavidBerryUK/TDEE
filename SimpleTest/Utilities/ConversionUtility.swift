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
    
}
