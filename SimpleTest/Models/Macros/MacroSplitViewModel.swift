//
//  MacroSplitViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 26/04/2026.
//
import Foundation
import Observation

/// Used in the main application to keep track of the users currently selected
///  macro split  options, and if the macro split section is in expanded mode
///
@Observable
final class MacroSplitViewModel {
    var selectedMacroId: UUID = FactoryMacroSplits.get().first!.id
}
