//
//  CalorieAdjustmentNewSectionView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI
import Observation

/// The New calorie-adjustment input section (story 023, inputs #10 / #11).
///
/// A layout redesign of the calorie-adjustment control, like `BodyFatPercentageNewSectionView`: there is
/// no expand/collapse panel — the controls live inline in the section header (the value entry drops to
/// its own line below). It composes two pieces that each honor their own Classic/New toggle over the
/// shared model (Decision 11 analog):
///
/// - **Method** (`calorieAdjustmentMethod`): a neutral `UICalorieAdjustmentMethodMenuButtonView` in
///   compact / regular, or the full-width segmented `UISegmentCalorieAdjustmentMethodView` reused
///   verbatim at accessibility sizes (Decision 10 analog).
/// - **Value** (`calorieAdjustment`): `UICalorieAdjustmentTextFieldEntry` (a `.numberPad` field with an
///   in-field `kCals` suffix), or the Classic `UISliderCalorieAdjustmentValue` reused when
///   `.calorieAdjustment` is Classic. **Shown only under Cut / Bulk** — a show/hide gate on
///   `calorieAdjustmentMethod != .maintain`, mirroring body fat's `== .manualEntry` gate (Decision 18
///   analog): Maintain carries no adjustment, so it shows no value field.
///
/// The New section gates the value field on `calorieAdjustmentMethod` **directly**, not via
/// `calorieAdjustmentShowSliders` — that flag is the Classic expanding-panel's open-state
/// (`SectionEditorCalorieAdjustment` is its only reader) and is left untouched. Calorie adjustment
/// carries **no results gate** (it is not in `isValid` / `hasError`), so — unlike the weight / height /
/// body-fat passes — this needs no `MetricRanges` gate move: `MetricRanges.calorieAdjustment` drives
/// only the entry's reject-and-nag. `MainSectionCaloriesAndAdjustments` selects this when either calorie
/// toggle is `.new`.
struct CalorieAdjustmentNewSectionView: View {

    @Bindable var model: ProfileViewModel
    @Environment(InputStyleManager.self) private var inputStyle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The one section-level message, driven by the value entry.
    @State private var error: String = ""

    private var isMethodNew: Bool { inputStyle.style(for: .calorieAdjustmentMethod) == .new }
    private var isValueNew: Bool { inputStyle.style(for: .calorieAdjustment) == .new }
    /// The gate: the value entry shows only under Cut / Bulk (Maintain carries no adjustment).
    private var isAdjusting: Bool { model.calorieAdjustmentMethod != .maintain }

    var body: some View {
        // At accessibility sizes the method slot gets its own full-width line so it is not squeezed;
        // otherwise it trails the header row (Decision 9 analog).
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? Spacing.small : 0) {
            HStack {
                UIIcon(icon: .calorie, style: .coloredBackgroundSolid)
                Text("Calorie Adjustment")
                    .font(.headline)
                Spacer(minLength: Spacing.large)
                if !dynamicTypeSize.isAccessibilitySize {
                    methodSlot
                }
            }
            if dynamicTypeSize.isAccessibilitySize {
                methodSlot
            }
            // The value entry is gated: shown only under Cut / Bulk. Maintain carries no adjustment, so
            // it shows no value field (Decision 18 analog).
            if isAdjusting {
                valueSlot
            }
            // The one section-level message sits under the header, driven by the value entry.
            UILabelValidationMessage(error)
        }
        .padding(Spacing.large)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        // Switching to Maintain hides the value field, so clear any pending message (Decision 18 analog).
        .onChange(of: model.calorieAdjustmentMethod) { _, new in
            if new == .maintain { error = "" }
        }
    }

    /// The method selector — honors the `calorieAdjustmentMethod` toggle (Decision 11 analog).
    @ViewBuilder
    private var methodSlot: some View {
        if isMethodNew, !dynamicTypeSize.isAccessibilitySize {
            // Compact / regular: the neutral menu button (Decision 10 analog).
            UICalorieAdjustmentMethodMenuButtonView(model: model)
        } else {
            // Classic toggle, or accessibility sizes: the segmented control reused verbatim.
            UISegmentCalorieAdjustmentMethodView(option: $model.calorieAdjustmentMethod)
        }
    }

    /// The value entry — honors the `calorieAdjustment` toggle; rendered only under Cut / Bulk. The New
    /// box is right-aligned to the card's right edge so it shares a right edge with every other value
    /// box.
    @ViewBuilder
    private var valueSlot: some View {
        if isValueNew {
            UICalorieAdjustmentTextFieldEntry(model: model, errorMessage: $error)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            // Classic value: the slider, reused unchanged.
            UISliderCalorieAdjustmentValue(model: model)
        }
    }
}

// Previews inject a manager over an isolated suite so flipping to `.new` here never writes to the
// owner's real `input.style.preferences` store (a `.standard` manager would).
private var previewManager: InputStyleManager {
    let defaults = UserDefaults(suiteName: "com.tdee.calorieAdjustmentPreview") ?? .standard
    let manager = InputStyleManager(defaults: defaults)
    manager.setStyle(.new, for: .calorieAdjustmentMethod)
    manager.setStyle(.new, for: .calorieAdjustment)
    return manager
}

#Preview("New — Cut") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return CalorieAdjustmentNewSectionView(model: model)
        .environment(previewManager)
}

#Preview("New — Maintain (no value field)") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    return CalorieAdjustmentNewSectionView(model: model)
        .environment(previewManager)
}
