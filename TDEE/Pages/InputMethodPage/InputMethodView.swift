//
//  InputMethodView.swift
//  TDEE
//
//  Story 023 (Input Method) — Task 1: the presenter. Lists every input with a Classic/New
//  segmented toggle, backed by the global InputStyleManager.
//

import SwiftUI

/// The user's surface for choosing an input style per input (Classic vs New).
///
/// A master "All inputs" selector at the top — a three-state Classic / Mixed / New control that
/// bulk-applies a style to every input at once (a convenience over the per-input store, not a
/// separate global value). "Mixed" is derived: it highlights when per-input overrides differ. Below
/// it, one segmented toggle per input, grouped like the main screen, lets the user fine-tune
/// individually. Each choice persists via `InputStyleManager`. The per-input "New" controls are
/// built input-by-input in later tasks; until then "New" is a stored preference with no visible
/// control yet.
struct InputMethodView: View {
    @Environment(InputStyleManager.self) private var manager
    @Environment(\.palette) private var palette

    var body: some View {
        List {
            SwiftUI.Section("All inputs") {
                masterRow
            }
            .listRowBackground(palette.surface)

            ForEach(sections, id: \.0) { section, inputs in
                SwiftUI.Section(section.title) {
                    ForEach(inputs, id: \.self) { input in
                        row(for: input)
                    }
                }
                .listRowBackground(palette.surface)
            }
        }
        .themedGroupedList(palette)
        .navigationTitle("Input Method")
    }

    /// Inputs grouped by section, in display order.
    private var sections: [(InputSection, [InputID])] {
        InputSection.allCases.map { section in
            (section, InputID.allCases.filter { $0.section == section })
        }
    }

    @ViewBuilder
    private func row(for input: InputID) -> some View {
        HStack {
            Text(input.label)

            Spacer(minLength: 12)

            Picker(
                "Style",
                selection: Binding(
                    get: { manager.style(for: input) },
                    set: { manager.setStyle($0, for: input) }
                )
            ) {
                ForEach(InputStyle.allCases, id: \.self) { style in
                    Text(style.label).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            .accessibilityLabel("Input style for \(input.label)")
            .accessibilityValue(manager.style(for: input).label)
        }
    }

    /// The master control: a three-state selector (Classic / Mixed / New) that sets every input at
    /// once. "Mixed" is derived from the per-input overrides rather than chosen, so a caption
    /// explains what selecting each side does.
    private var masterRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Picker(
                "All inputs",
                selection: Binding(
                    get: { manager.masterState },
                    set: { manager.applyMaster($0) }
                )
            ) {
                ForEach(InputMasterStyle.allCases, id: \.self) { style in
                    Text(style.label).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("All inputs")
            .accessibilityValue(manager.masterState.label)

            Text(masterCaption)
                .font(.caption)
                .foregroundStyle(palette.textSecondary)
        }
    }

    /// Explains the control: which bulk apply a side performs, and — when the per-input overrides
    /// differ — how many inputs are on each style.
    private var masterCaption: String {
        let counts = manager.styleCounts
        if counts.classic == 0 { return "Sets every input to New." }
        if counts.new == 0 { return "Sets every input to Classic." }
        return "Mixed — \(counts.classic) Classic, \(counts.new) New. Pick a side to set all."
    }
}

#Preview {
    let defaults = UserDefaults(suiteName: "InputMethodViewPreview")!
    NavigationStack {
        ThemedRoot(
            themeManager: ThemeManager(defaults: defaults),
            inputStyleManager: InputStyleManager(defaults: defaults)
        ) {
            InputMethodView()
        }
    }
}
