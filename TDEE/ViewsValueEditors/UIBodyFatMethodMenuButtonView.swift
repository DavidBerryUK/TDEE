//
//  UBodyFatMethodMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New body-fat calculation-method control (story 023, input #8) for compact and regular sizes.
///
/// A neutral `Menu` labelled "Method" that lists every `BodyFatOption` case and rebinds
/// `model.bodyFatPercentageMethod` — the Classic segmented control's 3-case pick (Omit / Estimate /
/// Manual Entry), surfaced as a dropdown. It mirrors the neutral menu buttons
/// (`UIActivityLevelMenuButtonView` / `UIWeightUomMenuButtonView`) and replaces
/// `UISegmentBodyFatCalcMethodView` without touching it — see `BodyFatPercentageNewSectionView`. At
/// accessibility sizes the section instead shows the full-width segmented `UISegmentBodyFatCalcMethodView`
/// reused verbatim (Decision 10 analog).
struct UBodyFatMethodMenuButtonView: View {

    @Bindable var model: ProfileViewModel

    var body: some View {
        Menu {
            ForEach(BodyFatOption.allCases, id: \.self) { option in
                Button {
                    model.bodyFatPercentageMethod = option
                } label: {
                    Text(option.displayName)
                }
            }
        } label: {
            Text("Method")
        }
        .accessibilityIdentifier("bodyFatMethodMenu")
    }
}

#Preview {
    UBodyFatMethodMenuButtonView(model: ProfileViewModel())
}
