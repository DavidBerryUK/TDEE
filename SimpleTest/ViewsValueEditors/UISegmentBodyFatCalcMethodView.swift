//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct UISegmentBodyFatCalcMethodView: View {

    @Binding var option: BodyFatOption

    var body: some View {
        Picker("BodyFatOption", selection: $option) {
            ForEach(BodyFatOption.allCases, id: \.self) { level in
                Text(level.displayName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: BodyFatOption = BodyFatOption.omit
    UISegmentBodyFatCalcMethodView(option: $option)
}
