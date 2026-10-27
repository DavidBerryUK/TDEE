//
//  WeightNewSectionView.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import SwiftUI
import Observation

/// The New weight input section (story 023, inputs #3 / #4).
///
/// A layout redesign of the weight control, like `AgeNewSectionView`: there is no expand/collapse
/// panel — the control lives inline in the section header. It composes two pieces that each honor
/// their own Classic/New toggle over the shared `model.weightUom` / `model.weight` (Decision 11):
///
/// - **Switcher** (`weightUom`): a neutral `UIWeightUomMenuButtonView` in compact / regular, or the
///   full-width segmented `UISegmentUomWeightView` reused verbatim at accessibility sizes
///   (Decision 10).
/// - **Value** (`weight`): `UIWeightTextFieldEntry` (1 field for kg / lb, 2 for stones & pounds, each
///   with an in-field UoM suffix), or the Classic `UIWheelPickerWeightView` reused when `.weight` is
///   Classic.
///
/// A unit switch re-derives the display from the stored kg and never mutates the model (Decision 13).
/// `MainSectionProfileInput` selects this when either weight toggle is `.new`.
struct WeightNewSectionView: View {

    @Bindable var model: ProfileViewModel
    @Environment(InputStyleManager.self) private var inputStyle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The one section-level message, driven by the value entry.
    @State private var error: String = ""

    private var isUomNew: Bool { inputStyle.style(for: .weightUom) == .new }
    private var isWeightNew: Bool { inputStyle.style(for: .weight) == .new }

    var body: some View {
        // At accessibility sizes the switcher and the value entry each get their own full-width line
        // so nothing is squeezed; otherwise the switcher trails the header row (Decision 9).
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? Spacing.small : 0) {
            HStack {
                UIIcon(icon: .weight, style: .coloredBackgroundSolid)
                Text("Weight")
                    .font(.headline)
                Spacer(minLength: Spacing.large)
                if !dynamicTypeSize.isAccessibilitySize {
                    switcher
                }
            }
            if dynamicTypeSize.isAccessibilitySize {
                switcher
            }
            valueSlot
            // The one section-level message sits under the header.
            UILabelValidationMessage(error)
        }
        .padding(Spacing.large)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }

    /// The unit switcher — honors the `weightUom` toggle (Decision 11).
    @ViewBuilder
    private var switcher: some View {
        if isUomNew, !dynamicTypeSize.isAccessibilitySize {
            // Compact / regular: the neutral menu button (Decision 10).
            UIWeightUomMenuButtonView(model: model)
        } else {
            // Classic toggle, or accessibility sizes: the segmented control reused verbatim.
            UISegmentUomWeightView(option: $model.weightUom)
        }
    }

    /// The value entry — honors the `weight` toggle (Decision 11). The New box is right-aligned to the
    /// card's right edge so it shares a right edge with every other value box; a compound UoM
    /// (stones & pounds) keeps each sub-field at the shared width and grows left from that edge.
    @ViewBuilder
    private var valueSlot: some View {
        if isWeightNew {
            UIWeightTextFieldEntry(model: model, errorMessage: $error)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            // Classic value: the wheel picker, reused unchanged.
            UIWheelPickerWeightView(value: $model.weight, unitOfMeasure: $model.weightUom)
        }
    }
}

#Preview {
    WeightNewSectionView(model: ProfileViewModel())
        .environment(InputStyleManager())
}
