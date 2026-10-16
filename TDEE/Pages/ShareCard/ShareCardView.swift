//
//  ShareCardView.swift
//  TDEE
//

import SwiftUI

/// What the share sheet hands to other apps.
/// Image and text are shared separately: iOS hides image-only targets (Instagram, etc.)
/// when text is mixed in with the image.
struct ShareContent: Identifiable {
    enum Format {
        case image
        case text
    }

    let id = UUID()
    let activityItems: [Any]

    /// Builds the share content for the current results in the requested format.
    @MainActor
    static func make(_ format: Format, model: ShareResultsModel, result: CalculatorResultViewModel) -> ShareContent {
        switch format {
        case .text:
            return ShareContent(activityItems: [model.shareText])
        case .image:
            let card = ShareCardView(model: model, result: result)
                .environment(\.colorScheme, .light)

            let renderer = ImageRenderer(content: card)
            renderer.scale = 3  // 1080 x 1350, the 4:5 portrait ratio social apps expect

            // Fall back to text if rendering fails so the button never does nothing
            guard let image = renderer.uiImage else {
                return ShareContent(activityItems: [model.shareText])
            }
            return ShareContent(activityItems: [image])
        }
    }
}

/// A fixed-size, always-light card summarising the calculation, rendered to an image for sharing.
struct ShareCardView: View {
    static let size = CGSize(width: 360, height: 450)

    let model: ShareResultsModel
    let result: CalculatorResultViewModel

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Daily Calories")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("\(result.caloriesAdjustedPerDay.formatted())")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Text("\(model.calorieAdjustmentText) · \(result.caloriesAdjustedPerWeek.formatted()) per week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 6) {
                Text(model.macroPresetText)
                    .font(.title3.weight(.semibold))
                HStack(spacing: 10) {
                    macroTile("protein", grams: result.proteinGrams, percent: result.proteinPercent, color: .red)
                    macroTile("carbs", grams: result.carbsGrams, percent: result.carbsPercent, color: .blue)
                    macroTile("fats", grams: result.fatsGrams, percent: result.fatsPercent, color: .teal)
                }
            }

            Spacer(minLength: 0)

            Text("\(model.genderText) · \(model.ageText) · \(model.heightText) · \(model.weightText)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("TDEE")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(28)
        .foregroundStyle(.primary)
        .frame(width: Self.size.width, height: Self.size.height)
        .background(Color.white)
    }

    private func macroTile(_ name: String, grams: Int, percent: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(grams)g")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("\(name) \(percent)%")
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1.5))
    }
}
