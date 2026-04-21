//
//  FactoryMacroSplits.swift
//  TempProteinFatsCarbsMixer
//
//  Created by David Berry on 18/04/2026.
//

import Foundation

final class FactoryMacroSplits {
    
    // MARK: - Stable IDs
    enum Id {
        static let balanced     = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        static let diet         = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        static let bodyBuilder  = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
        static let ketogenic    = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
        static let rest         = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!
        static let training     = UUID(uuidString: "66666666-6666-6666-6666-666666666666")!
        static let zone         = UUID(uuidString: "77777777-7777-7777-7777-777777777777")!
    }
    
    // MARK: - Factory
    static func get() -> [MacroSplitViewModel] {
        
        return [
            MacroSplitViewModel(id: Id.balanced,    name: "Balanced",     protein: 34, carbs: 33, fats: 33, ordinal: 1),
            MacroSplitViewModel(id: Id.diet,        name: "Diet",         protein: 40, carbs: 40, fats: 20, ordinal: 2),
            MacroSplitViewModel(id: Id.bodyBuilder, name: "Body Builder", protein: 40, carbs: 25, fats: 35, ordinal: 3),
            MacroSplitViewModel(id: Id.ketogenic,   name: "Ketogenic",    protein: 25, carbs: 5,  fats: 70, ordinal: 4),
            MacroSplitViewModel(id: Id.rest,        name: "Rest",         protein: 40, carbs: 35, fats: 25, ordinal: 5),
            MacroSplitViewModel(id: Id.training,    name: "Training",     protein: 30, carbs: 50, fats: 20, ordinal: 6),
            MacroSplitViewModel(id: Id.zone,        name: "Zone",         protein: 30, carbs: 30, fats: 40, ordinal: 7)
        ]
    }
}

