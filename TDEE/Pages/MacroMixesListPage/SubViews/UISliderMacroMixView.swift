//
//  UISliderMacroMixView.swift
//  TDEE
//
//  Created by David Berry on 15/04/2026.
//

import SwiftUI

struct UISliderMacroMixView: View {

    @Bindable var model: MacroSplitOptionModel
    @State private var proteinValue: Double = 0
    @State private var carbsValue: Double = 0
    @State private var fatsValue: Double = 0
    
    var body: some View {
        VStack {
            Text("Adjust protein and carbs first, then set fats last. The app will automatically keep everything balanced to 100%.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Grid(alignment: .leading) {
                GridRow {
                    Text("protein")
                        .font(.title)

                    Slider(value: Binding(
                        get: { Double(model.protein) },
                        set: { newValue in model.updateFromUiProtein(to: newValue) }
                    ), in: 0...100)
                    .frame(maxWidth: .infinity)

                    Text("\(model.protein)%")
                        .font(.body)
                        .frame(width: 46, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .gridColumnAlignment(.trailing)
                        
                }
                GridRow {
                    Text("carbs")
                        .font(.title)

                    Slider(value: Binding(
                        get: { Double(model.carbs) },
                        set: { newValue in model.updateFromUiCarbs(to: newValue) }
                    ), in: 0...100)
                    .frame(maxWidth: .infinity)

                    Text("\(model.carbs)%")
                        .font(.body)
                        .frame(width: 46, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .gridColumnAlignment(.trailing)
                }
                GridRow {
                    Text("fats")
                        .font(.title)

                    Slider(value: Binding(
                        get: { Double(model.fats) },
                        set: { newValue in model.updateFromUiFats(to: newValue) }
                    ), in: 0...100)
                    .frame(maxWidth: .infinity)

                    Text("\(model.fats)%")
                        .font(.body)
                        .frame(width: 46, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .gridColumnAlignment(.trailing)
                }
            }
        }
        .padding()
    }
}

#Preview {
    UISliderMacroMixView(model: MacroSplitOptionModel())
}
