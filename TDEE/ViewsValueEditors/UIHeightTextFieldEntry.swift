//
//  UIHeightTextFieldEntry.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New height value entry (story 023, input #6).
///
/// One numeric field for cm / inches, two (feet then an inches remainder) for feet & inches — each
/// carrying its unit as an in-field trailing suffix (`| 175 cm |`, `| 5 ft |` `| 9 in |`). Entry is
/// integer this pass (`.numberPad`), matching the Classic's integer wheels.
///
/// Each field keeps a local text buffer; the buffer commits to `model.height` (cm) only when
/// `HeightEntry` reports a complete, in-range entry (Decision 13). A unit switch re-derives the
/// buffers from the stored cm and never rewrites `model.height` (Decision 13). The one section-level
/// message is driven through `errorMessage`, owned by `HeightNewSectionView`.
///
/// A keyboard **Done** accessory key (Decision 17a, revisited this pass) dismisses the keyboard — the
/// first field to carry one. It is applied here so it can be back-ported to the age / weight entries
/// as a shared concern.
struct UIHeightTextFieldEntry: View {

    @Bindable var model: ProfileViewModel
    /// The one section-level message this entry drives ("" when valid), owned by `HeightNewSectionView`.
    @Binding var errorMessage: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// One local buffer per field, seeded on appear and re-derived from the stored cm on a unit or
    /// model change. A unit switch never rewrites `model.height` (Decision 13).
    @State private var singleText: String = ""
    @State private var feetText: String = ""
    @State private var inchesText: String = ""

    /// The focused field, so the Done key can resign first responder.
    @FocusState private var focusedField: Field?

    enum Field {
        case single
        case feet
        case inches
    }

    private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        Group {
            switch model.heightUom {
            case .centimeters, .inches:
                singleField
            case .feetAndInches:
                feetInchesFields
            }
        }
        .onAppear(perform: rederive)
        // Re-derive the display from the stored cm on a unit switch or a model change — never writing
        // back to the model (Decision 13).
        .onChange(of: model.heightUom) { _, _ in rederive() }
        .onChange(of: model.height) { _, _ in rederive() }
        // The Done accessory key (Decision 17a), shown above the keyboard for this entry's fields.
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") { focusedField = nil }
            }
        }
    }

    // MARK: - Fields

    /// A single field for cm / inches, with the unit as an in-field suffix.
    @ViewBuilder
    private var singleField: some View {
        field(text: $singleText, suffix: singleSuffix, focus: .single)
            .onChange(of: singleText) { _, _ in commit() }
    }

    /// Two fields for feet & inches. They stack at accessibility sizes so neither is squeezed; side
    /// by side otherwise (Decision 9).
    @ViewBuilder
    private var feetInchesFields: some View {
        VStack(spacing: isAccessibilitySize ? Spacing.small : 0) {
            HStack(spacing: Spacing.small) {
                field(text: $feetText, suffix: "ft", focus: .feet)
                    .onChange(of: feetText) { _, _ in commit() }
                if !isAccessibilitySize {
                    field(text: $inchesText, suffix: "in", focus: .inches)
                        .onChange(of: inchesText) { _, _ in commit() }
                }
            }
            if isAccessibilitySize {
                field(text: $inchesText, suffix: "in", focus: .inches)
                    .onChange(of: inchesText) { _, _ in commit() }
            }
        }
    }

    /// A bordered `.numberPad` field with an in-field UoM suffix (reusing the picker label's
    /// voice/color) and a focus tag for the Done key. Styling only — the caller attaches `onChange`.
    /// Uses the shared `UIValueFieldStyle` so this box matches every other numeric entry.
    @ViewBuilder
    private func field(text: Binding<String>, suffix: String, focus: Field) -> some View {
        TextField("Enter \(suffix)", text: text)
            .modifier(UIValueFieldStyle(suffix: suffix, fullWidth: isAccessibilitySize))
            .focused($focusedField, equals: focus)
    }

    // MARK: - Commit (buffer-and-commit; commit only on a complete, in-range entry)

    /// Validate the fields for the current unit and commit the cm on a complete, in-range entry.
    private func commit() {
        let status: HeightEntry.Status
        switch model.heightUom {
        case .centimeters, .inches:
            status = HeightEntry.validate(unit: model.heightUom, fields: [singleText])
        case .feetAndInches:
            status = HeightEntry.validate(unit: .feetAndInches, fields: [feetText, inchesText])
        }
        switch status {
        case .ok(let cm):
            // Commit only on a real change, so re-typing the same value doesn't re-trigger a save.
            if model.height != cm { model.height = cm }
            errorMessage = ""
        case .empty:
            errorMessage = "Height is required"
        case .outOfRange:
            errorMessage = outOfRangeMessage()
        case .unparseable:
            errorMessage = "Enter a valid height"
        }
    }

    /// The in-field UoM suffix for the single cm / inches field.
    private var singleSuffix: String {
        switch model.heightUom {
        case .centimeters: "cm"
        case .inches: "in"
        case .feetAndInches: ""
        }
    }

    /// The one out-of-range message. The inches remainder nags specifically (Decision 12); every other
    /// case reads in cm, the range's unit of authority.
    private func outOfRangeMessage() -> String {
        switch model.heightUom {
        case .feetAndInches:
            // A inches remainder of 12+ nags specifically; otherwise a general range message.
            if let remainder = Int(inchesText.trimmingCharacters(in: .whitespaces)), remainder >= 12 {
                return "Inches must be 0–11"
            }
            return "Height must be 100–272 cm"
        case .centimeters, .inches:
            return "Height must be 100–272 cm"
        }
    }

    // MARK: - Re-derive the display from the stored cm (never mutates the model)

    /// Mirror the Classic wheel's display: cm / inches round, feet & inches round — so the New control
    /// shows the same numbers as the Classic for the same stored cm.
    private func rederive() {
        errorMessage = ""
        let cm = model.height
        switch model.heightUom {
        case .centimeters:
            singleText = String(DisplayLength.asCentimeters(cm: cm))
        case .inches:
            singleText = String(DisplayLength.asInches(cm: cm))
        case .feetAndInches:
            feetText = String(LengthConverter.toFeet(cm))
            inchesText = String(LengthConverter.toRemainingInches(cm))
        }
    }
}

#Preview {
    UIHeightTextFieldEntry(model: ProfileViewModel(), errorMessage: .constant(""))
}
