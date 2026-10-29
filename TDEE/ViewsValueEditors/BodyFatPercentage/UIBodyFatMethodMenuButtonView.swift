//
//  UBodyFatMethodMenuButtonView.swift
//  TDEE
//
//  Created by David Berry on 20/10/2026.
//

import SwiftUI

/// The New body-fat calculation-method control (story 023, input #8) for compact and regular sizes.
///
/// A `Menu` whose label is the current method's full name (`Omit` / `Estimate` / `Manual Entry`) plus a
/// selector chevron, that rebinds `model.bodyFatPercentageMethod` — the Classic segmented control's
/// 3-case pick, surfaced as a dropdown. The full name and chevron make the control read as a value
/// picker, the discoverability fix for the old neutral "Method" label (Decision 10), mirroring the
/// other New menu buttons (`UIActivityLevelMenuButtonView` / `UIWeightUomMenuButtonView`), and
/// replacing `UISegmentBodyFatCalcMethodView` without touching it — see `BodyFatPercentageNewSectionView`.
/// At accessibility sizes the section instead shows the full-width segmented
/// `UISegmentBodyFatCalcMethodView` reused verbatim (Decision 10 analog).
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
            // Full name + a selector chevron, so the control reads as a value picker.
            HStack(spacing: 4) {
                Text(model.bodyFatPercentageMethod.displayName)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("bodyFatMethodMenu")
    }
}

#Preview {
    UBodyFatMethodMenuButtonView(model: ProfileViewModel())
}
