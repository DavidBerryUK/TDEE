//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorBodyFatPercentage: View {
    
    @Bindable var model: ProfileViewModel
        
    var body: some View {
        UILayoutExpandingPanel(
            isOpen: $model.bodyFatPercentageShowManualEntry,
            header: {
                UISegmentBodyFatCalcMethodView(option: $model.bodyFatPercentageMethod)
                    .padding(.horizontal, 8)
            }
        ) {
            UIWheelPickerBodyFatView(value: $model.bodyFatPercentage)
        }
    }
}

#Preview("omit") {
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .omit
    return SectionEditorBodyFatPercentage(model: model)
}

#Preview("Estimate") {
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .estimate
    return SectionEditorBodyFatPercentage(model: model)
}

#Preview("Manual Entry") {
    let model = ProfileViewModel()
    model.bodyFatPercentageMethod = .manualEntry
    model.bodyFatPercentage = 15.2
    return SectionEditorBodyFatPercentage(model: model)
}

