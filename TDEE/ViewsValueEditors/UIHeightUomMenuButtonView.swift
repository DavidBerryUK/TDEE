//
//  UIHeightUomMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New height unit switcher (story 023, input #5) for compact and regular sizes.
///
/// A neutral `Menu` labelled "Units" that rebinds `model.heightUom`. The value entry already shows the
/// current unit as an in-field suffix, so the button need not repeat it (Decision 10). At
/// accessibility sizes the section instead shows the full-width segmented `UISegmentUomLengthView`
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
            Text("Units")
        }
        .accessibilityIdentifier("heightUnitMenu")
    }
}

#Preview {
    UIHeightUomMenuButtonView(model: ProfileViewModel())
}
