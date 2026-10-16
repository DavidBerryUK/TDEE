//
//  WatchMainView.swift
//  TDEE Watch
//

import SwiftUI

/// Calories per day and macro targets for the current profile.
struct WatchMainView: View {

    let profile: ProfileViewModel
    let macroCollection: MacroSplitOptionsModelCollection
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
        List {
            Section {
                summary
            }
            .listRowBackground(Color.clear)

            Section {
                row("Gender", value: profile.gender.displayName) { WatchGenderView(profile: profile) }
                row("Age", value: "\(profile.age)") { WatchAgeView(profile: profile) }
                row("Weight", value: "\(Int(profile.weight.rounded())) kg") { WatchWeightView(profile: profile) }
                row("Height", value: "\(Int(profile.height.rounded())) cm") { WatchHeightView(profile: profile) }
                row("Activity", value: profile.activityLevel.displayName) { WatchActivityLevelView(profile: profile) }
                row("Body Fat", value: bodyFatSummary) { WatchBodyFatView(profile: profile) }
                row("Adjust", value: adjustmentSummary) { WatchCalorieAdjustmentView(profile: profile) }
                row("Macros", value: macroName) { WatchMacroPresetsView(profile: profile, macroCollection: macroCollection) }
            }
        }
        .navigationTitle("TDEE")
        .task(id: inputs) {
            result = await Calculator.calculate(person: profile)
        }
    }

    private var bodyFatSummary: String {
        profile.bodyFatPercentageMethod == .manualEntry
            ? String(format: "%.1f%%", profile.bodyFatPercentage)
            : profile.bodyFatPercentageMethod.displayName
    }

    private var macroName: String {
        macroCollection.items.first { $0.id == profile.selectedMacroId }?.name ?? "Custom"
    }

    private var adjustmentSummary: String {
        let method = profile.calorieAdjustmentMethod
        return method == .maintain
            ? method.displayName
            : "\(method.adjustmentPrefix)\(Int(profile.calorieAdjustment))"
    }

    @ViewBuilder
    private var summary: some View {
        VStack(spacing: 4) {
            if let message = result.message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(WatchPalette.textSecondary)
            } else {
                Text("\(result.caloriesAdjustedPerDay)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("calories per day")
                    .font(.footnote)
                    .foregroundStyle(WatchPalette.textSecondary)

                HStack {
                    macro("Protein", grams: result.proteinGrams, colour: WatchPalette.macroProtein)
                    macro("Carbs", grams: result.carbsGrams, colour: WatchPalette.macroCarbs)
                    macro("Fats", grams: result.fatsGrams, colour: WatchPalette.macroFat)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func row<Destination: View>(_ title: String, value: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(WatchPalette.textSecondary)
            }
        }
    }

    private func macro(_ name: String, grams: Int, colour: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(grams)g")
                .font(.headline)
                .foregroundStyle(colour)
            Text(name)
                .font(.caption2)
                .foregroundStyle(WatchPalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
