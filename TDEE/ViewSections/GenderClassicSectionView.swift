//
//  GenderClassicSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI
import Observation

/// The Classic gender input section (story 023) — today's segmented control.
///
/// The main input's section factory (`MainSectionProfileInput`) picks this or the future
/// `GenderNewSectionView` from `InputStyleManager`; every input currently resolves to Classic.
struct GenderClassicSectionView: View {

    @Bindable var model: ProfileViewModel
    @Bindable var sectionManager: SectionManagerViewModel
    let proxy: ScrollViewProxy?

    var body: some View {
        UILayoutSectionView(
            title: "Gender",
            icon: .gender,
            isExpanded: $sectionManager.genderIsExpanded,
            validationText: "",
            accessibilityId: "sectionGender",
            sectionId: "sectionGender",
            sectionSummaryValueView: {
                UISectionSummaryValueGender(model: model, sectionManager: sectionManager)
            },
            editorView: {
                UISegmentGenderView(option: $model.gender)
            },
            proxy: proxy
        )
    }
}

#Preview {
    @Previewable @State var sectionManager = SectionManagerViewModel()
    GenderClassicSectionView(model: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository), sectionManager: sectionManager, proxy: nil)
}
