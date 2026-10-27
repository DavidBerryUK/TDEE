//
//  HeightNewSectionView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI
import Observation

/// The New height input section (story 023, inputs #5 / #6).
///
/// A layout redesign of the height control, like `WeightNewSectionView`: there is no expand/collapse
/// panel — the control lives inline in the section header. It composes two pieces that each honor
/// their own Classic/New toggle over the shared `model.heightUom` / `model.height` (Decision 11):
///
/// - **Switcher** (`heightUom`): a neutral `UIHeightUomMenuButtonView` in compact / regular, or the
///   full-width segmented `UISegmentUomLengthView` reused verbatim at accessibility sizes
///   (Decision 10).
/// - **Value** (`height`): `UIHeightTextFieldEntry` (1 field for cm / inches, 2 for feet & inches,
///   each with an in-field UoM suffix), or the Classic `UIWheelPickerHeightView` reused when `.height`
///   is Classic.
///
/// A unit switch re-derives the display from the stored cm and never mutates the model (Decision 13).
/// `MainSectionProfileInput` selects this when either height toggle is `.new`.
struct HeightNewSectionView: View {

    @Bindable var model: ProfileViewModel
    @Environment(InputStyleManager.self) private var inputStyle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The one section-level message, driven by the value entry.
    @State private var error: String = ""

    private var isUomNew: Bool { inputStyle.style(for: .heightUom) == .new }
    private var isHeightNew: Bool { inputStyle.style(for: .height) == .new }

    var body: some View {
        // At accessibility sizes the switcher and the value entry each get their own full-width line
        // so nothing is squeezed; otherwise the switcher trails the header row (Decision 9).
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? Spacing.small : 0) {
            HStack {
                UIIcon(icon: .height, style: .coloredBackgroundSolid)
                Text("Height")
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

    /// The unit switcher — honors the `heightUom` toggle (Decision 11).
    @ViewBuilder
    private var switcher: some View {
        if isUomNew, !dynamicTypeSize.isAccessibilitySize {
            // Compact / regular: the neutral menu button (Decision 10).
            UIHeightUomMenuButtonView(model: model)
        } else {
            // Classic toggle, or accessibility sizes: the segmented control reused verbatim.
            UISegmentUomLengthView(option: $model.heightUom)
        }
    }

    /// The value entry — honors the `height` toggle (Decision 11). The New box is right-aligned to the
    /// card's right edge so it shares a right edge with every other value box; a compound UoM
    /// (feet & inches) keeps each sub-field at the shared width and grows left from that edge.
    @ViewBuilder
    private var valueSlot: some View {
        if isHeightNew {
            UIHeightTextFieldEntry(model: model, errorMessage: $error)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            // Classic value: the wheel picker, reused unchanged.
            UIWheelPickerHeightView(value: $model.height, unitOfMeasure: $model.heightUom)
        }
    }
}

#Preview {
    HeightNewSectionView(model: ProfileViewModel())
        .environment(InputStyleManager())
}
