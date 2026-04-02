//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentBodyFatCalcMethodView: View {
    
    @Binding var option: AppEnums.enumBodyFatOption
    
    var body: some View {
        Picker("Gender", selection: $option) {
            Text("Omitted").tag(AppEnums.enumBodyFatOption.DoNoUse)
            Text("Automatic").tag(AppEnums.enumBodyFatOption.Estimate)
            Text("Manual Entry").tag(AppEnums.enumBodyFatOption.ManualEntry)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: AppEnums.enumBodyFatOption = AppEnums.enumBodyFatOption.DoNoUse
    SegmentBodyFatCalcMethodView(option: $option)
}
