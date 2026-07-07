//
//  MacroSplitOptionsViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 26/04/2026.
//
import Foundation
import Observation

/// Tracks which macro split option the user has selected via the UI wheel picker
@Observable
final class MacroSplitOptionsViewModel {
    var selectedMacroId: UUID = FactoryMacroSplits.get().first!.id

    init() {}
}
