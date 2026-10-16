//
//  UIIcon.swift
//  TDEE
//
//  Created by David Berry on 07/04/2026.
//

import SwiftUI

private let iconCatalog: [Icon: IconModel] = [
    .gender: IconModel(id: .gender, label: "Gender", symbolSolid: "person.fill", symbolOutlined: "person", color: .blue),
    .age: IconModel(id: .age, label: "Age", symbolSolid: "calendar", symbolOutlined: "calendar", color: .red),
    .weight: IconModel(id: .weight, label: "Weight", symbolSolid: "scalemass.fill", symbolOutlined: "scalemass", color: .green),
    .height: IconModel(id: .height, label: "Height", symbolSolid: "ruler.fill", symbolOutlined: "ruler", color: .orange),
    .activityLevel: IconModel(id: .activityLevel, label: "Activity Level", symbolSolid: "bolt.fill", symbolOutlined: "bolt", color: .yellow),
    .bodyFat: IconModel(id: .bodyFat, label: "Body Fat %", symbolSolid: "chart.pie.fill", symbolOutlined: "chart.pie", color: .purple),
    .calorie: IconModel(id: .calorie, label: "Calories", symbolSolid: "flame.fill", symbolOutlined: "flame", color: .orange),
    .protein: IconModel(id: .protein, label: "Protein", symbolSolid: "dumbbell.fill", symbolOutlined: "dumbbell", color: .red),
    .carbs: IconModel(id: .carbs, label: "Carbs", symbolSolid: "leaf.fill", symbolOutlined: "leaf", color: .green),
    .fats: IconModel(id: .fats, label: "Fats", symbolSolid: "drop.fill", symbolOutlined: "drop", color: .yellow),
    .macroSplit: IconModel(id: .macroSplit, label: "Macro Split", symbolSolid: "fork.knife.circle.fill", symbolOutlined: "fork.knife", color: .yellow),
]

struct UIIcon: View {
    let icon: Icon
    let style: IconStyle
    
    var body: some View {
        if let iconInfo = iconCatalog[icon] {
            // Determine symbol and colors based on style
            let (symbol, foreground, background, cornerRadius): (String, Color, Color?, CGFloat?) = {
                switch style {
                case .coloredBackgroundOutline:
                    return (iconInfo.symbolOutlined, .white, iconInfo.color, 8)
                case .coloredBackgroundSolid:
                    return (iconInfo.symbolSolid, .white, iconInfo.color, 8)
                case .coloredOutline:
                    return (iconInfo.symbolOutlined, iconInfo.color, nil, nil)
                case .coloredSolid:
                    return (iconInfo.symbolSolid, iconInfo.color, nil, nil)
                case .plainSolid:
                    return (iconInfo.symbolSolid, .primary, nil, nil)
                case .plainOutline:
                    return (iconInfo.symbolOutlined, .primary, nil, nil)
                }
            }()
            
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(foreground)
                .frame(width: 38, height: 38)
                .background((background ?? Color.clear).gradient)
                .cornerRadius(cornerRadius ?? 0)
            
        } else {
            // Fallback if icon not found
            Image(systemName: "questionmark")
                .font(.system(size: 24, weight: .bold))
                .frame(width: 38, height: 38)
                .foregroundStyle(.gray)
        }
    }
}


#Preview {
    ScrollView{
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
            // Loop over the enum cases
            ForEach(Icon.allCases, id: \.self) { metric in
                if let iconInfo = iconCatalog[metric] {
                    // Label row spans all columns
                    GridRow {
                        Text(iconInfo.label)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .gridCellColumns(6) // <-- span all 6 icon columns
                    }
                    
                    // Icons row
                    GridRow {
                        UIIcon(icon: metric, style: .plainOutline)
                        UIIcon(icon: metric, style: .plainSolid)
                        UIIcon(icon: metric, style: .coloredOutline)
                        UIIcon(icon: metric, style: .coloredSolid)
                        UIIcon(icon: metric, style: .coloredBackgroundOutline)
                        UIIcon(icon: metric, style: .coloredBackgroundSolid)
                    }
                }
            }
        }.padding()
    }
    .background(Color(.systemBackground))
}
