//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorWeight: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        VStack {
            UISegmentUomWeightView(option: $model.weightUom).padding(.leading, 8).padding(.trailing, 8)
            UIWheelPickerWeightView(value: $model.weight, unitOfMeasure: $model.weightUom)
        }
    }
}

#Preview {
    SectionEditorWeight(model: ProfileViewModel())
}
