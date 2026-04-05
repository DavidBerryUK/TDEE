//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorHeight: View {
    
    @Bindable var model: ProfileInputViewModel
    
    var body: some View {
        VStack {
            UISegmentUomLengthView(option: $model.heightUom)
            UIWheelPickerHeightView(value: $model.height, unitOfMeasure: $model.heightUom)
        }
    }
}

#Preview {
    SectionEditorHeight(model: ProfileInputViewModel())
}
