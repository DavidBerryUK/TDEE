//
//  SwiftUIView.swift
//  SimpleTest
//
//  Created by David Berry on 02/04/2026.
//

import SwiftUI

struct SegmentGenderView: View {
    
    @Binding var option: enumGender
    
    var body: some View {
        Picker("Gender", selection: $option) {
            Text("Male").tag(enumGender.male)
            Text("Female").tag(enumGender.female)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var option: enumGender = enumGender.male
    SegmentGenderView(option: $option)
}
