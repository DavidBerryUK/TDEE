import SwiftUI

struct MacroInformationBarView: View {
    
    @Bindable var item: MacroSplitOptionModel
    
    private let minLabelWidth: CGFloat = 45
    
    var body: some View {
        GeometryReader { geo in
            let total = max(CGFloat(item.protein + item.carbs + item.fats), 1) // safety
            
            let pWidth = geo.size.width * CGFloat(item.protein) / total
            let cWidth = geo.size.width * CGFloat(item.carbs) / total
            let fWidth = geo.size.width * CGFloat(item.fats) / total
            
            VStack(alignment: .leading, spacing: 6) {
                
                ZStack {
                    // Subtle background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                    
                    // Bar segments
                    HStack(spacing: 0) {
                        segment(
                            label: "P",
                            color: UIStyle.Text.macroProtein,
                            width: pWidth,
                            value: item.protein
                        )
                        
                        segment(
                            label: "C",
                            color: UIStyle.Text.macroCarbs,
                            width: cWidth,
                            value: item.carbs
                        )
                        
                        segment(
                            label: "F",
                            color: UIStyle.Text.macroFats,
                            width: fWidth,
                            value: item.fats
                        )
                    }
                }
                .frame(height: 24) // slightly taller for readability
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(height: 44)
       
    }
    
    @ViewBuilder
    private func segment(label: String, color: Color, width: CGFloat, value: Int) -> some View {
        ZStack {
            color
            
            if width > minLabelWidth {
                Text("\(label) \(value)%")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(color.readableTextColor())
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .allowsTightening(true)
            }
        }
        .frame(width: width)
    }
}
