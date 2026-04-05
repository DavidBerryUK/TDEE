//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorWeight: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        VStack {
            UISegmentUomWeightView(option: $model.weightUom)
            UIWheelPickerWeightView(value: $model.weight, unitOfMeasure: $model.weightUom)
        }
    }
}

#Preview {
    SectionEditorWeight(model: ProfileInputViewModel())
}
