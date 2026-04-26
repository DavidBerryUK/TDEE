import Foundation
import Observation

/// Single Macro Psplit Option
@Observable
public final class MacroSplitOptionModel : Identifiable, Hashable {
    
    public static func == (lhs: MacroSplitOptionModel, rhs: MacroSplitOptionModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    public var id: UUID
    public var name :String
    
    public var protein: Int
    public var carbs: Int
    public var fats: Int
    
    public var ordinal: Int
    
    public init() {
        self.id = UUID()
        self.name = ""
        self.protein = 40
        self.carbs = 30
        self.fats = 30
        self.ordinal = -1
        normalizeAll()
    }
    
    public init(id: UUID = UUID(), name: String = "", protein: Int = 40, carbs: Int = 30, fats: Int = 30,  ordinal: Int = 0) {
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.ordinal = ordinal
        normalizeAll()
    }
    
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func clone() -> MacroSplitOptionModel {
        return MacroSplitOptionModel(id : self.id, name: self.name, protein: self.protein, carbs: self.carbs, fats: self.fats, ordinal: self.ordinal)
    }
}


extension MacroSplitOptionModel {

    // MARK: - Public API for sliders
    func updateProtein(to newValue: Double) {
        normalizeAfterProteinChange(newValue: newValue)
    }
    
    func updateCarbs(to newValue: Double) {
        normalizeAfterCarbsChange(newValue: newValue)
    }
    
    func updateFats(to newValue: Double) {
        normalizeAfterFatsChange(newValue: newValue)
    }
    
    // MARK: - Helpers
    private func snapToStep(_ value: Double, step: Int = 5, min: Int = 0, max: Int = 100) -> Int {
        let snapped = Int(value / Double(step)) * step
        return Swift.max(min, Swift.min(max, snapped))
    }
    
    private func clampValueTo100(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }
    
    private var overflow: Int {
        100 - (protein + carbs + fats)
    }
    
    private func normalizeAll() {
        protein = clampValueTo100(protein)
        carbs = clampValueTo100( carbs + overflow )
        fats = clampValueTo100( fats + overflow )
    }
    
    private func normalizeAfterProteinChange(newValue: Double) {
        protein = snapToStep(newValue)
        carbs = clampValueTo100( carbs + overflow )
        fats = clampValueTo100( fats + overflow )
    }
    
    private func normalizeAfterCarbsChange(newValue: Double) {
        carbs = snapToStep(newValue)
        fats = clampValueTo100( fats + overflow )
        protein = clampValueTo100( protein + overflow )
    }
    
    private func normalizeAfterFatsChange(newValue: Double) {
        fats = snapToStep(newValue)
        carbs = clampValueTo100( carbs + overflow )
        protein = clampValueTo100( protein + overflow )
    }
}
