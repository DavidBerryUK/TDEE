//
//  UILayoutSectionView.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UILayoutSectionView<SectionSummaryValueView: View, EditorView: View>: View {
    
    let title: String
    let icon : EnumIcon
    @Binding var isExpanded: Bool
    
    let sectionSummaryValueView: () -> SectionSummaryValueView
    let editorView: () -> EditorView
    
    var body: some View {
        VStack(spacing: 4) {
            
            HStack {
                UIIcon(icon: icon, style: .coloredBackgroundSolid)
                Text(title)
                    .font(.headline)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: title)
                Spacer()
                sectionSummaryValueView()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                
                editorView()
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }
        }.padding(16) // padding around the row
    }
}

#Preview {
    @Previewable @State var model = ProfileViewModel()
    
    UILayoutSectionView(
        title: "Weight",
        icon: .weight,
        isExpanded: $model.weightIsExpanded,
        sectionSummaryValueView: {
            Text("75 kg")
        },
        editorView: {
            HStack {
                Text("Content goes here")
                Spacer()
            }
        }
    )
}
