//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentBodyFatCalcMethodView: View {
    
    @Binding var option: enumBodyFatOption
    
    var body: some View {
        Picker("Gender", selection: $option) {
            ForEach(enumBodyFatOption.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level) 
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: enumBodyFatOption = enumBodyFatOption.omit
    SegmentBodyFatCalcMethodView(option: $option)
}
