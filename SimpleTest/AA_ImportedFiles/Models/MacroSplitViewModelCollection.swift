import Observation
import Foundation
import SwiftUI

@Observable
final class MacroSplitViewModelCollection {
    
    // Source of truth
    private var items: [MacroSplitViewModel] = []
    
    var sortedItems: [MacroSplitViewModel] {
        items.sorted { $0.ordinal < $1.ordinal }
    }
    
    // Default empty
    init() {
        self.items = []
    }
    
    // Initialise with existing items
    init(items: [MacroSplitViewModel]) {
        self.items = items
    }
    
    // MARK: - CRUD
    
    func add(_ item: MacroSplitViewModel) {        
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
    
    func update(_ item: MacroSplitViewModel) {
        if let existing = items.first(where: { $0.id == item.id }) {
            existing.name = item.name
            existing.protein = item.protein
            existing.carbs = item.carbs
            existing.fats = item.fats
            existing.ordinal = item.ordinal
        }
    }
    
    func remove(_ item: MacroSplitViewModel) {
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
