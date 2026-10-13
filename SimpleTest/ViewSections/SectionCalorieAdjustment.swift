//
//  SectionCalorieAdjustment.swift
//  SimpleTest
//
//  Created by David Berry on 09/04/2026.
//

import SwiftUI
import Observation

/// A view section for adjusting daily calorie intake.
struct SectionCalorieAdjustment: View {

    @Bindable var profile: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {

        UILayoutSectionView(
            title: "\(profile.calorieAdjustmentMethod.sectionTitle)",
            icon: .calorie,
            isExpanded: $sectionManager.calorieAdjustmentExpanded,
            validationText: "",
            accessibilityId: "sectionCalorieAdjustment",
            sectionId: "sectionCalorieAdjustment",
            sectionSummaryValueView: {
                UISectionSummaryValueCalorieAdjustment(model: profile, sectionManager: sectionManager)
            },
            editorView: {
                SectionEditorCalorieAdjustment(model: profile)
            },
            proxy: proxy
        )
    }
}

#Preview("Cut") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return SectionCalorieAdjustment(profile: model, sectionManager: sectionManager, proxy: nil)
}

#Preview("Maintain") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    return SectionCalorieAdjustment(profile: model, sectionManager: sectionManager, proxy: nil)
}

#Preview("Bulk") {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return SectionCalorieAdjustment(profile: model, sectionManager: sectionManager, proxy: nil)
}

