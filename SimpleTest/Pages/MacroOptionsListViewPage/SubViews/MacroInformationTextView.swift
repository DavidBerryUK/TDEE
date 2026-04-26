//
//  MacroInformationTextView.swift
//  TempProteinFatsCarbsMixer
//
//  Created by David Berry on 19/04/2026.
//

import SwiftUI

struct MacroInformationTextView: View {
    
    @Bindable var item: MacroSplitOptionModel
    
    var body: some View {
        HStack(spacing: 12) {
            
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color.macroProtein)
                Text("protein \(item.protein)%")
            }
            
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.macroCarbs)
                Text("carbs \(item.carbs)%")
            }
            
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(Color.macroFats)
                Text("fats \(item.fats)%")
            }
            
            Spacer()
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    MacroInformationTextView(item: MacroSplitOptionModel())
}
