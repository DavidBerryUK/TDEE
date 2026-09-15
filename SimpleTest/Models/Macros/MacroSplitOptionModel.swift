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
        let normalized = MacroSplitOptionModel.normalizeAll(protein: 40, carbs: 30, fats: 30)
        self.protein   = normalized.protein
        self.carbs     = normalized.carbs
        self.fats      = normalized.fats
    }

    public init(id: UUID = UUID(), name: String = "", protein: Int = 40, carbs: Int = 30, fats: Int = 30, ordinal: Int = 0) {
        self.id = id
        self.name = name
        let normalized = MacroSplitOptionModel.normalizeAll(protein: protein, carbs: carbs, fats: fats)
        self.protein   = normalized.protein
        self.carbs     = normalized.carbs
        self.fats      = normalized.fats
        self.ordinal   = ordinal
    }
    

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public func clone() -> MacroSplitOptionModel {
        return MacroSplitOptionModel(id : self.id, name: self.name, protein: self.protein, carbs: self.carbs, fats: self.fats, ordinal: self.ordinal)
    }

    // MARK: - Public API for sliders

    func updateProtein(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterProteinChange(newValue: newValue, originalCarbs: self.carbs, originalFats: self.fats)
        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

    func updateCarbs(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterCarbsChange(newValue: newValue, originalProtein: self.protein, originalFats: self.fats)
        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

    func updateFats(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterFatsChange(newValue: newValue, originalProtein: self.protein, originalCarbs: self.carbs)
        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }
}
