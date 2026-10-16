//
//  WatchMainView.swift
//  TDEE Watch
//

import SwiftUI

/// Calories per day and macro targets for the current profile.
struct WatchMainView: View {

    let profile: ProfileViewModel
    @State private var result = CalculatorResultViewModel()

    /// Everything the result depends on. `.task(id:)` re-runs the calculation when it changes.
    private struct Inputs: Hashable {
        var gender: Gender
        var age: Int
        var weight: Double
        var height: Double
        var activityLevel: ActivityLevel
        var bodyFatMethod: BodyFatOption
        var bodyFatPercentage: Double
        var adjustmentMethod: CalorieAdjustmentMethod
        var adjustment: Double
        var protein: Int
        var carbs: Int
        var fats: Int
    }

    private var inputs: Inputs {
        Inputs(
            gender: profile.gender,
            age: profile.age,
            weight: profile.weight,
            height: profile.height,
            activityLevel: profile.activityLevel,
            bodyFatMethod: profile.bodyFatPercentageMethod,
            bodyFatPercentage: profile.bodyFatPercentage,
            adjustmentMethod: profile.calorieAdjustmentMethod,
            adjustment: profile.calorieAdjustment,
            protein: profile.protein,
            carbs: profile.carbs,
            fats: profile.fats)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let message = result.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(result.caloriesAdjustedPerDay)")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("calories per day")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    HStack {
                        macro("Protein", grams: result.proteinGrams, colour: .red)
                        macro("Carbs", grams: result.carbsGrams, colour: .blue)
                        macro("Fats", grams: result.fatsGrams, colour: .yellow)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .navigationTitle("TDEE")
        .task(id: inputs) {
            result = await Calculator.calculate(person: profile)
        }
    }

    private func macro(_ name: String, grams: Int, colour: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(grams)g")
                .font(.headline)
                .foregroundStyle(colour)
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
