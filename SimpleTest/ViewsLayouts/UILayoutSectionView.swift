//
//  UILayoutSectionView.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UILayoutSectionView<ValueView: View, Content: View>: View {
    
    let title: String
    @Binding var isExpanded: Bool
    
    let valueView: () -> ValueView
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                Text(title)
                    .font(.headline)                
                Spacer()
                valueView()
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
                
                content()
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }
        }.padding()
    }
}

#Preview {
    @Previewable @State var model = ProfileInputViewModel()
    
    UILayoutSectionView(
        title: "Weight",
        isExpanded: $model.weightIsExpanded,
        valueView: {
            Text("75 kg")
        },
        content: {
            HStack {
                Text("Content goes here")
                Spacer()
            }
        }
    )
}
