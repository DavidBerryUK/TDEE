//
//  UIWeightUomMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import SwiftUI

/// The New weight unit switcher (story 023, input #3) for compact and regular sizes.
///
/// A neutral `Menu` labelled "Units" that rebinds `model.weightUom`. The value entry already shows the
/// current unit as an in-field suffix, so the button need not repeat it (Decision 10). At
/// accessibility sizes the section instead shows the full-width segmented `UISegmentUomWeightView`
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
            Text("Units")
        }
        .accessibilityIdentifier("weightUnitMenu")
    }
}

#Preview {
    UIWeightUomMenuButtonView(model: ProfileViewModel())
}
