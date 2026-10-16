//
//  MacroInformationTextView.swift
//  TempProteinFatsCarbsMixer
//
//  Created by David Berry on 19/04/2026.
//

import SwiftUI

struct MacroInformationTextView: View {
    @Environment(\.palette) private var palette
    
    @Bindable var item: MacroSplitOptionModel
    
    var body: some View {
        HStack(spacing: 12) {
            
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(palette.macroProtein)
                Text("protein \(item.protein)%")
            }
            
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(palette.macroCarbs)
                Text("carbs \(item.carbs)%")
            }
            
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(palette.macroFat)
                Text("fats \(item.fats)%")
            }
            
            Spacer()
        }
        .font(.caption2)
        .foregroundStyle(palette.textSecondary)
    }
}

#Preview {
    MacroInformationTextView(item: MacroSplitOptionModel())
}
