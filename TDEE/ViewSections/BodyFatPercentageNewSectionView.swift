//
//  BodyFatPercentageNewSectionView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI
import Observation

/// The New body-fat-percentage input section (story 023, inputs #7 / #8).
///
/// A layout redesign of the body-fat control, like `WeightNewSectionView`: there is no expand/collapse
/// panel — the controls live inline in the section header (the % value entry drops to its own line
/// below). It composes two pieces that each honor their own Classic/New toggle over the shared model
/// (Decision 11 analog):
///
/// - **Method** (`bodyFatMethod`): a neutral `UIBodyFatMethodMenuButtonView` in compact / regular, or
///   the full-width segmented `UISegmentBodyFatCalcMethodView` reused verbatim at accessibility sizes
///   (Decision 10 analog).
/// - **Value** (`bodyFatPercentage`): `UIBodyFatPercentageTextFieldEntry` (a `.decimalPad` field with
///   an in-field `%` suffix), or the Classic `UIWheelPickerBodyFatView` reused when `.bodyFatPercentage`
///   is Classic. **Shown only under the `.manualEntry` method** — a show/hide gate (Decision 18), the
///   one element with no precedent in the weight / height passes, which relate their pieces by a unit
///   switch rather than a gate.
///
/// The New section gates the % field on `bodyFatPercentageMethod == .manualEntry` **directly**, not via
/// `bodyFatPercentageShowManualEntry` — that flag is the Classic expanding-panel's open-state and is
/// unused here (no `UILayoutExpandingPanel`). `MainSectionProfileInput` selects this when either
/// body-fat toggle is `.new`.
struct BodyFatPercentageNewSectionView: View {

    @Bindable var model: ProfileViewModel
    @Environment(InputStyleManager.self) private var inputStyle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The one section-level message, driven by the % entry.
    @State private var error: String = ""

    private var isMethodNew: Bool { inputStyle.style(for: .bodyFatMethod) == .new }
    private var isPercentageNew: Bool { inputStyle.style(for: .bodyFatPercentage) == .new }
    /// The gate: the % value entry shows only under Manual Entry (Decision 18).
    private var isManualEntry: Bool { model.bodyFatPercentageMethod == .manualEntry }

    var body: some View {
        // At accessibility sizes the method slot gets its own full-width line so it is not squeezed;
        // otherwise it trails the header row (Decision 9 analog).
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? Spacing.small : 0) {
            HStack {
                UIIcon(icon: .bodyFat, style: .coloredBackgroundSolid)
                Text("Body Fat Percentage")
                    .font(.headline)
                Spacer(minLength: Spacing.large)
                if !dynamicTypeSize.isAccessibilitySize {
                    methodSlot
                }
            }
            if dynamicTypeSize.isAccessibilitySize {
                methodSlot
            }
            // The % value entry is gated: shown only for Manual Entry (Decision 18). Omit / Estimate
            // carry no % value, so they show no % field at all.
            if isManualEntry {
                valueSlot
            }
            // The one section-level message sits under the header, driven by the % entry.
            UILabelValidationMessage(error)
        }
        .padding(Spacing.large)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        // Leaving Manual Entry hides the % field, so clear any pending message (Decision 18).
        .onChange(of: model.bodyFatPercentageMethod) { _, new in
            if new != .manualEntry { error = "" }
        }
    }

    /// The method selector — honors the `bodyFatMethod` toggle (Decision 11 analog).
    @ViewBuilder
    private var methodSlot: some View {
        if isMethodNew, !dynamicTypeSize.isAccessibilitySize {
            // Compact / regular: the neutral menu button (Decision 10 analog).
            UBodyFatMethodMenuButtonView(model: model)
        } else {
            // Classic toggle, or accessibility sizes: the segmented control reused verbatim.
            UISegmentBodyFatCalcMethodView(option: $model.bodyFatPercentageMethod)
        }
    }

    /// The % value entry — honors the `bodyFatPercentage` toggle; rendered only for Manual Entry. The
    /// New box is right-aligned to the card's right edge so it shares a right edge with every other
    /// value box.
    @ViewBuilder
    private var valueSlot: some View {
        if isPercentageNew {
            UBodyFatPercentageTextFieldEntry(model: model, errorMessage: $error)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            // Classic value: the wheel picker, reused unchanged.
            UIWheelPickerBodyFatView(value: $model.bodyFatPercentage)
        }
    }
}

#Preview {
    BodyFatPercentageNewSectionView(model: ProfileViewModel())
        .environment(InputStyleManager())
}
