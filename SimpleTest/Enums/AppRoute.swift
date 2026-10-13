//
//  AppRoute.swift
//  SimpleTest
//
//  Created by David Berry on 21/04/2026.
//


public enum AppRoute: Hashable {
    case system
    case maintainMacroConfig
    case theme
    case about
    case macroEditorCreate
    case macroEditorEdit(MacroSplitOptionModel)
}

