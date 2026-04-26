//
//  MacroSplitViewModel.swift
//  SimpleTest
//
//  Created by David Berry on 26/04/2026.
//
import Foundation
import Combine
import Observation

/// Used in the main application to keep track of the users currently selected
///  macro mix options, and if the macro mix section is in expanded mode
///
@Observable
final class MacroSplitViewModel : ObservableObject  {
    var isExpanded : Bool = false
    var selectedMacroId: UUID = FactoryMacroSplits.get().first!.id
}
