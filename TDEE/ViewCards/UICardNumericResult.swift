//
//  UICardNumericResult.swift
//  TDEE
//
//  Created by David Berry on 06/04/2026.
//

import SwiftUI

/// A numeric result card displaying a value with a title and optional suffix.
struct UICardNumericResult: View {
    @Environment(\.palette) private var palette

    /// The descriptive title for this result
    var title : String
    /// The numeric value to display
    var value : Int
    /// An optional suffix to append to the value (e.g., "g" for grams), shown as a dimmer trailing glyph
    /// so the value stays the primary figure.
    var suffix : String = ""
    /// An optional color for the card border and background tint
    var color : Color? = nil
    /// An optional percentage shown after the title, de-emphasised (smaller + dimmer) so the gram value
    /// stays the primary figure. The macro cards pass it; every other caller leaves it `nil`.
    var percent : Int? = nil
    /// When `true` the card fills its row's height, so a sibling that wraps to a second line doesn't leave
    /// the others shorter. The macro row turns this on; it stays `false` by default because the calorie
    /// cards sit inside a `maxHeight: .infinity` section and must not stretch to fill it.
    var equalizeHeight : Bool = false

    var body: some View {

        VStack(alignment: .center, spacing: 6.0) {
            HStack(alignment: .firstTextBaseline,spacing:0) {
                Text("\(Int(value))")
                    .font(.largeTitle)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: value)
                // The unit (e.g. "g") reads as a dimmer trailing glyph; the value stays primary.
                if !suffix.isEmpty {
                    Text(suffix)
                        .foregroundStyle(palette.textSecondary)
                }
            }
            // The label, optionally followed by a de-emphasised percentage. Kept to one line — it shrinks to
            // fit rather than wrap — so the three macro cards stay a uniform height.
            labelLine
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: equalizeHeight ? .infinity : nil)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color?.opacity(0.1) ?? palette.textSecondary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color ?? palette.highlight, lineWidth: 1.5)
                // The neon bloom on the outline — tinted by the card's own colour (the macro colour when
                // present, else the house highlight). `nil` for every theme that doesn't opt in → unchanged.
                .neonGlowBloom(palette.glow, color: color ?? palette.highlight)
        )
        // The lit-tube core (a bright inner line) on the card's own outline — the part that reads as "neon" on a
        // light field. No-op for every theme that doesn't set a `tubeCore`, so the border alone is unchanged.
        .neonTube(palette.glow, radius: 12)
    }

    /// The label plus, when present, a smaller, dimmer percentage on the same baseline.
    @ViewBuilder
    private var labelLine: some View {
        if let percent {
            Text(title)
                .font(.callout)
            // The "NN%" is smaller and dimmer than the label — secondary to the gram value.
                + Text(" \(percent)%")
                    .font(.caption)
                    .foregroundStyle(palette.textSecondary)
        } else {
            Text(title)
                .font(.callout)
        }
    }
}

#Preview {
    VStack{
        HStack{
            UICardNumericResult(title: "Calories per day", value: 2500)
            UICardNumericResult(title: "Calories per week", value: 2500 * 7)
        }
        HStack{
            UICardNumericResult(title: "Carbs", value: 230, suffix:"g", color: .blue, percent: 50, equalizeHeight: true)
            UICardNumericResult(title: "Fats", value: 142, suffix:"g", color: .mint, percent: 25, equalizeHeight: true)
            UICardNumericResult(title: "Protein", value: 222, suffix:"g", color: .red, percent: 25, equalizeHeight: true)
        }
    }.padding(8)
}
