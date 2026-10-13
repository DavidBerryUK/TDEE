//
//  MacroSplitViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 26/04/2026.
//
import Foundation
import Observation

/// Manages the selected macro split option and expansion state.
@Observable
final class MacroSplitViewModel {
    /// The UUID of the currently selected macro split option
    var selectedMacroId: UUID = FactoryMacroSplits.get().first?.id ?? UUID()
}
