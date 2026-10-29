import SwiftUI

struct UISliderCalorieAdjustmentValue: View {

    @Bindable var model: ProfileViewModel

    // Slider range constants - imported from CalorieAdjustmentConstants
    private static let minAdjustment: Double = CalorieAdjustmentConstants.minAdjustment
    private static let maxAdjustment: Double = CalorieAdjustmentConstants.maxAdjustment
    private static let adjustmentStep: Double = CalorieAdjustmentConstants.adjustmentStep

    var body: some View {

        var perDay = Int(model.calorieAdjustment)
        var perWeek = Int(model.calorieAdjustment * 7)
        var adjustmentTextPerDay = ""
        var adjustmentTextPerWeek = ""

        switch(model.calorieAdjustmentMethod ) {
        case .cut:
            adjustmentTextPerDay = "Reduce Calories per day by"
            adjustmentTextPerWeek = "Reduce Calories per week by"
        case .maintain:
            adjustmentTextPerDay = "Maintain"
            adjustmentTextPerWeek = "Maintain"
            perDay = 0
            perWeek = 0
        case .bulk:
            adjustmentTextPerDay = "Increase Calories per day by"
            adjustmentTextPerWeek = "Increase Calories per week by"
        }

        return Grid(alignment: .leading, horizontalSpacing: Spacing.large, verticalSpacing: Spacing.medium) { // <-- FIX 1 & 2: Using constants for spacing
            GridRow {
                Text(adjustmentTextPerDay)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: adjustmentTextPerDay)
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                    .gridColumnAlignment(.leading)

                // Keeping the size hardcoded for now; ideal next step is to standardize this font size if used elsewhere.
                Text("\(perDay)")
                    .font(.system(size: 28, weight: .regular, design: .default))
                    .monospacedDigit()
                    .gridColumnAlignment(.trailing)
            }

            GridRow {
                Text(adjustmentTextPerWeek)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: adjustmentTextPerWeek)
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                    .gridColumnAlignment(.leading)

                Text("\(perWeek)")
                    .font(.system(size: 28, weight: .regular, design: .default))
                    .monospacedDigit()
                    .gridColumnAlignment(.trailing)
            }

            GridRow {
                Slider(
                    value: $model.calorieAdjustment,
                    in: Self.minAdjustment...Self.maxAdjustment,
                    step: Self.adjustmentStep
                )
                .gridCellColumns(2)
                .accessibilityLabel("Calorie adjustment slider")
                .accessibilityValue("\(Int(model.calorieAdjustment)) calories")
                .accessibilityHint("Adjust calorie intake by sliding left or right")
            }
        }
    }
}

#Preview("Cut") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .cut
    model.calorieAdjustment = 250
    return UISliderCalorieAdjustmentValue(model: model)
}

#Preview("Bulk") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .bulk
    model.calorieAdjustment = 500
    return UISliderCalorieAdjustmentValue(model: model)
}

#Preview("Maintain") {
    let model = ProfileViewModel()
    model.calorieAdjustmentMethod = .maintain
    return UISliderCalorieAdjustmentValue(model: model)
}
