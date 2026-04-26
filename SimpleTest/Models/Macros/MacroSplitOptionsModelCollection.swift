import Observation
import Foundation
import SwiftUI


/// Collection of all the Macro Split Options
@Observable
final class MacroSplitOptionsModelCollection {
    
    // Source of truth
    public var items: [MacroSplitOptionModel] = []
    
    var sortedItems: [MacroSplitOptionModel] {
        items.sorted { $0.ordinal < $1.ordinal }
    }
    
    // Default empty
    init() {
        self.items = []
    }
    
    // Initialise with existing items
    init(items: [MacroSplitOptionModel]) {
        self.items = items
    }
    
    // MARK: - CRUD
    
    func add(_ item: MacroSplitOptionModel) {        
        item.ordinal = -1
        items.append(item)
        reindex()
    }
    
    private func reindex() {
        let sorted = items.sorted { $0.ordinal < $1.ordinal }
        
        for (index, item) in sorted.enumerated() {
            item.ordinal = index
        }
    }
    
    func update(_ item: MacroSplitOptionModel) {
        if let existing = items.first(where: { $0.id == item.id }) {
            existing.name = item.name
            existing.protein = item.protein
            existing.carbs = item.carbs
            existing.fats = item.fats
            existing.ordinal = item.ordinal
        }
    }
    
    func remove(_ item: MacroSplitOptionModel) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        var updated = sortedItems
        updated.move(fromOffsets: source, toOffset: destination)
        
        // Reassign ordinals
        for (index, item) in updated.enumerated() {
            item.ordinal = index
        }
        
        items = updated
    }
}
