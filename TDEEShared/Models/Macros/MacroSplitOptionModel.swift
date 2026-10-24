import Foundation
import Observation

/// Single Macro Psplit Option
@Observable
public final class MacroSplitOptionModel : Identifiable, Hashable {

    public static let stepSize = 5

    public static func == (lhs: MacroSplitOptionModel, rhs: MacroSplitOptionModel) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: UUID
    public var name :String
    public var isSelected: Bool

    public var protein: Int
    public var carbs: Int
    public var fats: Int

    public var ordinal: Int
    public var isCustom: Bool  // true if user-created, false if system preset

    public init() {
        self.id = UUID()
        self.name = ""
        self.protein = 40
        self.carbs = 30
        self.fats = 30
        self.ordinal = -1
        self.isSelected = false
        self.isCustom = false
        let normalized = MacroSplitOptionModel.validateOnInit(protein: 40, carbs: 30, fats: 30)
        self.protein   = normalized.protein
        self.carbs     = normalized.carbs
        self.fats      = normalized.fats
    }

    public init(id: UUID = UUID(), name: String = "", protein: Int = 40, carbs: Int = 30, fats: Int = 30, ordinal: Int = 0, isSelected: Bool = false, isCustom: Bool = false) {
        self.id = id
        self.name = name
        let normalized = MacroSplitOptionModel.validateOnInit(protein: protein, carbs: carbs, fats: fats)
        self.protein   = normalized.protein
        self.carbs     = normalized.carbs
        self.fats      = normalized.fats
        self.ordinal   = ordinal
        self.isSelected = isSelected
        self.isCustom = isCustom
    }

    public func clone() -> MacroSplitOptionModel {
        return MacroSplitOptionModel(id: self.id, name: self.name, protein: self.protein, carbs: self.carbs, fats: self.fats, ordinal: self.ordinal, isSelected: self.isSelected, isCustom: self.isCustom)
    }

    private static func validateOnInit(protein: Int, carbs: Int, fats: Int) -> (protein: Int, carbs: Int, fats: Int) {
        MacroSplitOptionModel.normalizeAll(protein: protein, carbs: carbs, fats: fats)
    }

    public func updateFromUiProtein(to newValue: Double) {
        let snapValue = Self.snapToStep(newValue)
        if snapValue == self.protein {
            return
        }

        let result = normalizeAfterProteinChange(snapValue)

        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

    public func updateFromUiCarbs(to newValue: Double) {
        let snapValue = Self.snapToStep(newValue)
        if snapValue == self.carbs {
            return
        }

        let result = normalizeAfterCarbsChange(snapValue)

        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

    public func updateFromUiFats(to newValue: Double) {
        let snapValue = Self.snapToStep(newValue)
        if snapValue == self.fats {
            return
        }

        let result = normalizeAfterFatsChange(snapValue)

        self.protein = result.protein
        self.carbs   = result.carbs
        self.fats    = result.fats
    }

    private func normalizeAfterProteinChange(_ newValue: Int) -> (protein: Int, carbs: Int, fats: Int) {
        var snapshotCarbs: Int = self.carbs
        var snapshotFats: Int = self.fats
        var overflow: Int = 0

        overflow = 100 - (newValue + snapshotCarbs + snapshotFats)

        if overflow != 0 {
            snapshotCarbs = Self.snapToStep(snapshotCarbs + overflow)
        }

        overflow = 100 - (newValue + snapshotCarbs + snapshotFats)

        if overflow != 0 {
            snapshotFats = Self.snapToStep(snapshotFats + overflow)
        }
        return (
            newValue,
            snapshotCarbs,
            snapshotFats
        )
    }

    private func normalizeAfterCarbsChange(_ newValue: Int) -> (protein: Int, carbs: Int, fats: Int) {
        var snapshotProtein = self.protein
        var snapshotFats = self.fats
        var overflow: Int = 0

        overflow = 100 - (snapshotProtein + newValue + snapshotFats)

        if overflow != 0 {
            snapshotFats = Self.snapToStep(snapshotFats + overflow)
        }

        overflow = 100 - (snapshotProtein + newValue + snapshotFats)

        if overflow != 0 {
            snapshotProtein = Self.snapToStep(snapshotProtein + overflow)
        }

        return (
            snapshotProtein,
            newValue,
            snapshotFats
        )
    }

    private func normalizeAfterFatsChange(_ newValue: Int) -> (protein: Int, carbs: Int, fats: Int) {
        var snapshotProtein = self.protein
        var snapshotCarbs = self.carbs
        var overflow: Int = 0

        overflow = 100 - (snapshotProtein + snapshotCarbs + newValue)

        if overflow != 0 {
            snapshotCarbs = Self.snapToStep(snapshotCarbs + overflow)
        }

        overflow = 100 - (snapshotProtein + snapshotCarbs + newValue)

        if overflow != 0 {
            snapshotProtein = Self.snapToStep(snapshotProtein + overflow)
        }

        return (
            snapshotProtein,
            snapshotCarbs,
            newValue
        )
    }

    // MARK: - Shared rounding/clamping helpers

    // Single source of truth for the 5% step + [0,100] clamp, used by the live UI path
    // (updateFromUi* / normalizeAfter*Change), the init/clone normalization
    // (normalizeAll / adjustByDiff, in MacroSplitOptionsNormalization.swift), and the tests.
    static func snapToStep(_ value: Double) -> Int {
        let snapped = Int(value / Double(stepSize)) * stepSize
        return clampValueTo100(snapped)
    }

    static func snapToStep(_ value: Int) -> Int {
        let snapped = Int(value / stepSize) * stepSize
        return clampValueTo100(snapped)
    }

    static func clampValueTo100(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }

}
