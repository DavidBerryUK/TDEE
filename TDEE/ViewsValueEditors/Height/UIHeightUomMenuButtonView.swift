//
//  UIHeightUomMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New height unit switcher (story 023, input #5) for compact and regular sizes.
///
/// A `Menu` whose label is the current unit's full name (`Centimeters` / `Inches` / `Feet & Inches`)
/// plus a selector chevron, that rebinds `model.heightUom`. The full name and chevron make the control
/// read as a value picker — the discoverability fix for the old neutral "Units" label (Decision 10).
/// At accessibility sizes the section instead shows the full-width segmented `UISegmentUomLengthView`
/// (reused verbatim) — see `HeightNewSectionView`.
struct UIHeightUomMenuButtonView: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Menu {
            ForEach(OptionLength.allCases, id: \.self) { unit in
                Button {
                    model.heightUom = unit
                } label: {
                    Text(unit.displayName)
                }
            }
        } label: {
            // Full name + a selector chevron, so the control reads as a value picker.
            HStack(spacing: 4) {
                Text(model.heightUom.fullName)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("heightUnitMenu")
    }
}

#Preview {
    UIHeightUomMenuButtonView(model: ProfileViewModel())
}
