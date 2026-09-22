//
//  SectionEditorWeight.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct SectionEditorHeight: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
        VStack {
            UISegmentUomLengthView(option: $model.heightUom)
                .padding(.leading, 8)
                .padding(.trailing, 8)
            UIWheelPickerHeightView(value: $model.height, unitOfMeasure: $model.heightUom)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    SectionEditorHeight(model: ProfileViewModel())
}
