//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorBodyFatPercentage: View {
    
    @Bindable var model: ProfileInputViewModel
        
    var body: some View {
        UILayoutExpandingPanel(
            isOpen: $model.bodyFatPercentageShowManualEntry,
            header: {
                UISegmentBodyFatCalcMethodView(option: $model.bodyFatPercentageMethod)
            }
        ) {
            UIWheelPickerBodyFatView(value: $model.bodyFatPercentage)
        }
    }
}

#Preview("omit") {
    let model = ProfileInputViewModel()
    model.bodyFatPercentageMethod = .omit
    return SectionEditorBodyFatPercentage(model: model)
}

#Preview("Estimate") {
    let model = ProfileInputViewModel()
    model.bodyFatPercentageMethod = .estimate
    return SectionEditorBodyFatPercentage(model: model)
}

#Preview("Manual Entry") {
    let model = ProfileInputViewModel()
    model.bodyFatPercentageMethod = .manualEntry
    model.bodyFatPercentage = 15.2
    return SectionEditorBodyFatPercentage(model: model)
}

