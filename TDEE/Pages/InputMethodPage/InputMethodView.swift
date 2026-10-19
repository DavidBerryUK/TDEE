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
/// One segmented toggle per input, grouped like the main screen. Each choice persists via
/// `InputStyleManager`. The per-input "New" controls are built input-by-input in later tasks;
/// until then "New" is a stored preference with no visible control yet.
struct InputMethodView: View {
    @Environment(InputStyleManager.self) private var manager
    @Environment(\.palette) private var palette

    var body: some View {
        List {
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
