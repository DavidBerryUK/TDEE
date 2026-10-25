//
//  AppRoute.swift
//  TDEE
//
//  Created by David Berry on 21/04/2026.
//


public enum AppRoute: Hashable {
    case system
    case maintainMacroConfig
    case theme
    case about
    case inputMethod
    case macroEditorCreate
    case macroEditorEdit(MacroSplitOptionModel)
    case profiles
    case profileEditor(item: ProfileSummary?)
}

/// How a list page opens an editor onto the detail navigation stack.
///
/// On iPad a list lives in the sidebar but its editor should appear in the detail column:
/// - `append`: stack the editor on whatever the detail already shows — used when the list is
///   itself inside the detail stack (e.g. reached via the system menu), so "Back" returns to it.
/// - `replaceDetail`: open the editor at the *root* of the detail stack — used by the sidebar's
///   lists, so "Back" returns to the main screen instead of a screen the detail toolbar had
///   pushed on top (theme, etc.).
enum EditorPushStyle {
    case append
    case replaceDetail
}

