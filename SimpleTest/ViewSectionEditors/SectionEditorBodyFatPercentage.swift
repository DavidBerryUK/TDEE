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
        VStack {
            UISegmentBodyFatCalcMethodView(option: $model.bodyFatPercentageMethod)
            UIWheelPickerBodyFatView(value: $model.bodyFatPercentage)
        }
    }
}

#Preview {
    SectionEditorBodyFatPercentage(model: ProfileInputViewModel())
}
