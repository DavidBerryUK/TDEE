//
//  UISliderMacroMixView.swift
//  SimpleTest
//
//  Created by David Berry on 15/04/2026.
//

import SwiftUI

struct UISliderMacroMixViewOLD: View {
    
    @Bindable var model: ProfileViewModel
    
    var body: some View {
    VStack{
        Text("Adjust protein and carbs first, then set fats last. The app will automatically keep everything balanced to 100%.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        Grid(alignment: .leading) {
            GridRow {
                Text("protein")
                    .font(.title)
                
                Slider(value: Binding(
                    get: { Double(model.protein) },
                    set: { newValue in model.updateProtein(to: newValue) }
                ), in: 0...100, step: 5)
                .frame(maxWidth: .infinity)
                
                Text("\(model.protein)%")
                    .font(.body)
                    .gridColumnAlignment(.trailing)
            }
            GridRow {
                Text("carbs")
                    .font(.title)
                
                Slider(value: Binding(
                    get: { Double(model.carbs) },
                    set: { newValue in model.updateCarbs(to: newValue) }
                ), in: 0...100, step: 5)
                .frame(maxWidth: .infinity)
                
                Text("\(model.carbs)%")
                    .font(.body)
                    .gridColumnAlignment(.trailing)
            }
            GridRow {
                Text("fats")
                    .font(.title)
                
                Slider(value: Binding(
                    get: { Double(model.fats) },
                    set: { newValue in model.updateFats(to: newValue) }
                ), in: 0...100, step: 5)
                .frame(maxWidth: .infinity)
                
                Text("\(model.fats)%")
                    .font(.body)
                    .gridColumnAlignment(.trailing)
            }
        }
    }
    .padding()
}
}
#Preview {
    UISliderMacroMixViewOLD(model: ProfileViewModel())
}
