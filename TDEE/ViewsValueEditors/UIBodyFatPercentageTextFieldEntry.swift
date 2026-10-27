//
//  UBodyFatPercentageTextFieldEntry.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New body-fat-percentage value entry (story 023, input #7).
///
/// A single numeric field with the unit as an in-field trailing suffix (`| 15.7 % |`). Entry is
/// **decimal** this pass (`.decimalPad`, Decision 20) — the story's first decimal entry — matching the
/// Classic's integer + decimal wheels; the buffer commits to `model.bodyFatPercentage` only when
/// `BodyFatPercentageEntry` reports a complete, in-range entry (rounded to 1 dp). A model change
/// re-derives the buffer from the stored value and never rewrites the model except on a real
/// difference. The one section-level message is driven through `errorMessage`, owned by
/// `BodyFatPercentageNewSectionView`.
///
/// This entry is rendered by its section **only under the `.manualEntry` method** — the gate
/// (Decision 18). A keyboard **Done** accessory key (the height pattern) dismisses the keyboard.
struct UBodyFatPercentageTextFieldEntry: View {

    @Bindable var model: ProfileViewModel
    /// The one section-level message this entry drives ("" when valid), owned by
    /// `BodyFatPercentageNewSectionView`.
    @Binding var errorMessage: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The local buffer, seeded on appear and re-derived from the stored value on a model change.
    @State private var text: String = ""

    /// The focused field, so the Done key can resign first responder.
    @FocusState private var isFocused: Bool

    private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        field(text: $text, suffix: "%")
            .onChange(of: text) { _, _ in commit() }
            .onAppear(perform: rederive)
            // Re-derive the display from the stored value on a model change — never writing back
            // (a unit switch has no analogue here, but a load / reset does).
            .onChange(of: model.bodyFatPercentage) { _, _ in rederive() }
            // The Done accessory key (the height pattern), shown above the keyboard for this field.
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { isFocused = false }
                }
            }
    }

    // MARK: - Field

    /// A bordered `.decimalPad` field with an in-field `%` suffix (reusing the picker label's
    /// voice/color) and a focus tag for the Done key. Styling only — the caller attaches `onChange`.
    /// Uses the shared `UIValueFieldStyle` so this box matches every other numeric entry.
    @ViewBuilder
    private func field(text: Binding<String>, suffix: String) -> some View {
        TextField("Enter \(suffix)", text: text)
            .modifier(UIValueFieldStyle(suffix: suffix, keyboardType: .decimalPad, fullWidth: isAccessibilitySize))
            .focused($isFocused)
    }

    // MARK: - Commit (buffer-and-commit; commit only on a complete, in-range entry)

    /// Validate the field and commit the percentage on a complete, in-range entry.
    private func commit() {
        switch BodyFatPercentageEntry.validate(text) {
        case .ok(let value):
            // Commit only on a real change, so re-typing the same value doesn't re-trigger a save.
            if model.bodyFatPercentage != value { model.bodyFatPercentage = value }
            errorMessage = ""
        case .empty:
            errorMessage = "Body Fat is required"
        case .outOfRange:
            errorMessage = "Body Fat must be 5–50%"
        case .unparseable:
            errorMessage = "Enter a valid body fat percentage"
        }
    }

    // MARK: - Re-derive the display from the stored value (never mutates the model)

    /// Mirror the Classic wheel's display: the stored value as a 1-dp percentage.
    private func rederive() {
        errorMessage = ""
        text = String(model.bodyFatPercentage)
    }
}

#Preview {
    UBodyFatPercentageTextFieldEntry(model: ProfileViewModel(), errorMessage: .constant(""))
}
