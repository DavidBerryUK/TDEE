//
//  UIWeightTextFieldEntry.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import SwiftUI

/// The New weight value entry (story 023, input #4).
///
/// One numeric field for kg / pounds, two (stones then a pounds remainder) for stones & pounds — each
/// carrying its unit as an in-field trailing suffix (`| 70 kg |`, `| 11 st |` `| 3 lb |`). Entry is
/// integer this pass (`.numberPad`, Decision 16), matching the Classic's integer wheels.
///
/// Each field keeps a local text buffer; the buffer commits to `model.weight` (kg) only when
/// `WeightEntry` reports a complete, in-range entry (Decision 13). A unit switch re-derives the
/// buffers from the stored kg and never rewrites `model.weight` (Decision 13). The one section-level
/// message is driven through `errorMessage`, owned by `WeightNewSectionView`.
struct UIWeightTextFieldEntry: View {

    @Bindable var model: ProfileViewModel
    /// The one section-level message this entry drives ("" when valid), owned by `WeightNewSectionView`.
    @Binding var errorMessage: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// One local buffer per field, seeded on appear and re-derived from the stored kg on a unit or
    /// model change. A unit switch never rewrites `model.weight` (Decision 13).
    @State private var singleText: String = ""
    @State private var stonesText: String = ""
    @State private var poundsText: String = ""

    private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        Group {
            switch model.weightUom {
            case .kilograms, .pounds:
                singleField
            case .stonesAndPounds:
                stonesPoundsFields
            }
        }
        .onAppear(perform: rederive)
        // Re-derive the display from the stored kg on a unit switch or a model change — never writing
        // back to the model (Decision 13).
        .onChange(of: model.weightUom) { _, _ in rederive() }
        .onChange(of: model.weight) { _, _ in rederive() }
    }

    // MARK: - Fields

    /// A single field for kg / pounds, with the unit as an in-field suffix.
    @ViewBuilder
    private var singleField: some View {
        field(text: $singleText, suffix: singleSuffix)
            .onChange(of: singleText) { _, _ in commit() }
    }

    /// Two fields for stones & pounds. They stack at accessibility sizes so neither is squeezed; side
    /// by side otherwise (Decision 9).
    @ViewBuilder
    private var stonesPoundsFields: some View {
        VStack(spacing: isAccessibilitySize ? Spacing.small : 0) {
            HStack(spacing: Spacing.small) {
                field(text: $stonesText, suffix: "st")
                    .onChange(of: stonesText) { _, _ in commit() }
                if !isAccessibilitySize {
                    field(text: $poundsText, suffix: "lb")
                        .onChange(of: poundsText) { _, _ in commit() }
                }
            }
            if isAccessibilitySize {
                field(text: $poundsText, suffix: "lb")
                    .onChange(of: poundsText) { _, _ in commit() }
            }
        }
    }

    /// A bordered `.numberPad` field with an in-field UoM suffix (reusing the picker label's
    /// voice/color). Styling only — the caller attaches `onChange`.
    @ViewBuilder
    private func field(text: Binding<String>, suffix: String) -> some View {
        TextField("Enter \(suffix)", text: text)
            .modifier(WeightFieldStyle(suffix: suffix, fullWidth: isAccessibilitySize))
    }

    // MARK: - Commit (buffer-and-commit; commit only on a complete, in-range entry)

    /// Validate the fields for the current unit and commit the kg on a complete, in-range entry.
    private func commit() {
        let status: WeightEntry.Status
        switch model.weightUom {
        case .kilograms, .pounds:
            status = WeightEntry.validate(unit: model.weightUom, fields: [singleText])
        case .stonesAndPounds:
            status = WeightEntry.validate(unit: .stonesAndPounds, fields: [stonesText, poundsText])
        }
        switch status {
        case .ok(let kg):
            // Commit only on a real change, so re-typing the same value doesn't re-trigger a save.
            if model.weight != kg { model.weight = kg }
            errorMessage = ""
        case .empty:
            errorMessage = "Weight is required"
        case .outOfRange:
            errorMessage = outOfRangeMessage()
        case .unparseable:
            errorMessage = "Enter a valid weight"
        }
    }

    /// The in-field UoM suffix for the single kg / pounds field.
    private var singleSuffix: String {
        switch model.weightUom {
        case .kilograms: "kg"
        case .pounds: "lb"
        case .stonesAndPounds: ""
        }
    }

    /// The one out-of-range message, in the current unit (Decision 12's "reject and nag" for the
    /// stones remainder).
    private func outOfRangeMessage() -> String {
        switch model.weightUom {
        case .kilograms:
            return "Weight must be 20–300 kg"
        case .pounds:
            return "Weight must be 44–661 lb"
        case .stonesAndPounds:
            // A pounds remainder of 14+ nags specifically; otherwise a general stones message.
            if let remainder = Int(poundsText.trimmingCharacters(in: .whitespaces)), remainder >= 14 {
                return "Pounds must be 0–13"
            }
            return "Weight must be 0–40 st"
        }
    }

    // MARK: - Re-derive the display from the stored kg (never mutates the model)

    /// Mirror the Classic wheel's display: kg rounds, pounds/stones floor — so the New control shows
    /// the same numbers as the Classic for the same stored kg.
    private func rederive() {
        errorMessage = ""
        let kg = model.weight
        switch model.weightUom {
        case .kilograms:
            singleText = String(Int(round(kg)))
        case .pounds:
            singleText = String(WeightConvertor.toPounds(kg))
        case .stonesAndPounds:
            let totalPounds = WeightConvertor.toPounds(kg)
            stonesText = String(totalPounds / 14)
            poundsText = String(totalPounds % 14)
        }
    }
}

/// Bordered `.numberPad` styling with an in-field trailing UoM suffix.
private struct WeightFieldStyle: ViewModifier {
    let suffix: String
    let fullWidth: Bool

    func body(content: Content) -> some View {
        content
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            // Leave room on the right for the in-field UoM suffix.
            .padding(.trailing, 30)
            .frame(maxWidth: fullWidth ? .infinity : 96)
            .overlay(alignment: .trailing) {
                UITextPickerLabel(suffix).padding(.trailing, 8)
            }
    }
}

#Preview {
    UIWeightTextFieldEntry(model: ProfileViewModel(), errorMessage: .constant(""))
}
