//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentGenderView: View {
    
    @Binding var option: AppEnums.enumGender
    
    var body: some View {
        Picker("Gender", selection: $option) {
            Text("Male").tag(AppEnums.enumGender.male)
            Text("Female").tag(AppEnums.enumGender.female)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: AppEnums.enumGender = AppEnums.enumGender.male
    SegmentGenderView(option: $option)
}
