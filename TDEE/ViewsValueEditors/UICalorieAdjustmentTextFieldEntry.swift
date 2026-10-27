//
//  UICalorieAdjustmentTextFieldEntry.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New calorie-adjustment value entry (story 023, input #11).
///
/// A single numeric field with the unit as an in-field trailing suffix (`| 250 kCals |`). Entry is
/// integer this pass (`.numberPad`), matching the Classic slider's whole-kcal granularity; the buffer
/// commits to `model.calorieAdjustment` only when `CalorieAdjustmentEntry` reports a complete, in-range
/// entry (0–1000). A model change re-derives the buffer from the stored value and never rewrites the
/// model except on a real difference. The one section-level message is driven through `errorMessage`,
/// owned by `CalorieAdjustmentNewSectionView`.
///
/// This entry is rendered by its section **only under Cut / Bulk** (Maintain carries no adjustment) —
/// the gate (Decision 18 analog). A keyboard **Done** accessory key (the height / body-fat pattern)
/// dismisses the keyboard.
struct UICalorieAdjustmentTextFieldEntry: View {

    @Bindable var model: ProfileViewModel
    /// The one section-level message this entry drives ("" when valid), owned by
    /// `CalorieAdjustmentNewSectionView`.
    @Binding var errorMessage: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The local buffer, seeded on appear and re-derived from the stored value on a model change.
    @State private var text: String = ""

    /// The focused field, so the Done key can resign first responder.
    @FocusState private var isFocused: Bool

    private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        field(text: $text, suffix: "kCals")
            .onChange(of: text) { _, _ in commit() }
            .onAppear(perform: rederive)
            // Re-derive the display from the stored value on a model change — never writing back (a
            // method switch has no analogue here, but a load / reset does).
            .onChange(of: model.calorieAdjustment) { _, _ in rederive() }
            // The Done accessory key (the height / body-fat pattern), shown above the keyboard.
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { isFocused = false }
                }
            }
    }

    // MARK: - Field

    /// A bordered `.numberPad` field with an in-field `kCals` suffix (reusing the picker label's
    /// voice/color) and a focus tag for the Done key. Styling only — the caller attaches `onChange`.
    /// Uses the shared `UIValueFieldStyle` with a wider suffix reserve for `kCals`; same box width as
    /// every other numeric entry.
    @ViewBuilder
    private func field(text: Binding<String>, suffix: String) -> some View {
        TextField("Enter \(suffix)", text: text)
            .modifier(UIValueFieldStyle(suffix: suffix, suffixReserve: 44, fullWidth: isAccessibilitySize))
            .focused($isFocused)
    }

    // MARK: - Commit (buffer-and-commit; commit only on a complete, in-range entry)

    /// Validate the field and commit the adjustment on a complete, in-range entry.
    private func commit() {
        switch CalorieAdjustmentEntry.validate(text) {
        case .ok(let calories):
            // Commit only on a real change, so re-typing the same value doesn't re-trigger a save.
            if model.calorieAdjustment != calories { model.calorieAdjustment = calories }
            errorMessage = ""
        case .empty:
            errorMessage = "Calorie Adjustment is required"
        case .outOfRange:
            errorMessage = "Calories must be 0–1000"
        case .unparseable:
            errorMessage = "Enter a valid calorie adjustment"
        }
    }

    // MARK: - Re-derive the display from the stored value (never mutates the model)

    /// Mirror the Classic slider's display: the stored kcal/day as a whole number.
    private func rederive() {
        errorMessage = ""
        text = String(Int(model.calorieAdjustment))
    }
}

#Preview {
    UICalorieAdjustmentTextFieldEntry(model: ProfileViewModel(), errorMessage: .constant(""))
}
