//
//  UIWeightUomMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import SwiftUI

/// The New weight unit switcher (story 023, input #3) for compact and regular sizes.
///
/// A `Menu` whose label is the current unit's full name (`Kilograms` / `Pounds` / `Stones & Pounds`)
/// plus a selector chevron, that rebinds `model.weightUom`. The full name and chevron make the control
/// read as a value picker — the discoverability fix for the old neutral "Units" label (Decision 10).
/// At accessibility sizes the section instead shows the full-width segmented `UISegmentUomWeightView`
/// (reused verbatim) — see `WeightNewSectionView`.
struct UIWeightUomMenuButtonView: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Menu {
            ForEach(OptionWeight.allCases, id: \.self) { unit in
                Button {
                    model.weightUom = unit
                } label: {
                    Text(unit.displayName)
                }
            }
        } label: {
            // Full name + a selector chevron, so the control reads as a value picker.
            HStack(spacing: 4) {
                Text(model.weightUom.fullName)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("weightUnitMenu")
    }
}

#Preview {
    UIWeightUomMenuButtonView(model: ProfileViewModel())
}
