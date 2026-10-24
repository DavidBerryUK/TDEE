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
    /// False until the first calculation finishes, so launch never flashes "0".
    @State private var hasResult = false

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
                row("Weight", value: profile.weight == 0 ? "Not set" : weightSummary,
                    isMissing: missingFields.contains(.weight)) { WatchWeightView(profile: profile) }
                row("Height", value: profile.height == 0 ? "Not set" : heightSummary,
                    isMissing: missingFields.contains(.height)) { WatchHeightView(profile: profile) }
                row("Activity", value: profile.activityLevel.displayName) { WatchActivityLevelView(profile: profile) }
                row("Body Fat", value: bodyFatSummary, isMissing: missingFields.contains(.bodyFat)) { WatchBodyFatView(profile: profile) }
                row("Goal", value: adjustmentSummary) { WatchCalorieAdjustmentView(profile: profile) }
                row("Macros", value: macroName) { WatchMacroPresetsView(profile: profile, macroCollection: macroCollection) }
            }
        }
        .navigationTitle("TDEE")
        .task(id: inputs) {
            result = await Calculator.calculate(person: profile)
            hasResult = true
        }
    }

    /// Inputs a new profile has not set yet, in the order the user should fill them in.
    private var missingFields: [MissingField] {
        var fields: [MissingField] = []
        if profile.weight == 0 { fields.append(.weight) }
        if profile.height == 0 { fields.append(.height) }
        if profile.bodyFatPercentageMethod == .manualEntry,
           !WatchRanges.bodyFatPercent.contains(profile.bodyFatPercentage) { fields.append(.bodyFat) }
        return fields
    }

    private enum MissingField: String {
        case weight, height, bodyFat = "body fat"
    }

    @ViewBuilder
    private func screen(for field: MissingField) -> some View {
        switch field {
        case .weight: WatchWeightView(profile: profile)
        case .height: WatchHeightView(profile: profile)
        case .bodyFat: WatchBodyFatView(profile: profile)
        }
    }

    private var bodyFatSummary: String {
        guard profile.bodyFatPercentageMethod == .manualEntry else { return profile.bodyFatPercentageMethod.displayName }
        return WatchRanges.bodyFatPercent.contains(profile.bodyFatPercentage)
            ? (profile.bodyFatPercentage / 100).formatted(.percent.precision(.fractionLength(1)))
            : "Not set"
    }

    private var macroName: String {
        macroCollection.items.first { $0.id == profile.selectedMacroId }?.name ?? "Custom"
    }

    private var adjustmentSummary: String {
        let method = profile.calorieAdjustmentMethod
        return method == .maintain
            ? method.goalName
            : "\(method == .cut ? "−" : "+")\(Int(profile.calorieAdjustment)) kcal"
    }

    /// Weight in the user's selected unit (source of truth is kilograms): "70 kg", "154 lb", "11 st 3 lb".
    private var weightSummary: String {
        let unit = profile.weightUom
        switch unit {
        case .kilograms:
            return "\(DisplayWeight.asMajorValue(weight: profile.weight, unit: unit)) kg"
        case .pounds:
            return "\(DisplayWeight.asMajorValue(weight: profile.weight, unit: unit)) lb"
        case .stonesAndPounds:
            return "\(DisplayWeight.asMajorValue(weight: profile.weight, unit: unit)) st "
                + "\(DisplayWeight.asMinorValue(weight: profile.weight, unit: unit)) lb"
        }
    }

    /// Height in the user's selected unit (source of truth is centimetres): "173 cm", "68 in", "5 ft 8 in".
    private var heightSummary: String {
        let unit = profile.heightUom
        switch unit {
        case .centimeters:
            return "\(DisplayLength.asMajorValue(length: profile.height, unit: unit)) cm"
        case .inches:
            return "\(DisplayLength.asMajorValue(length: profile.height, unit: unit)) in"
        case .feetAndInches:
            return "\(DisplayLength.asMajorValue(length: profile.height, unit: unit)) ft "
                + "\(DisplayLength.asMinorValue(length: profile.height, unit: unit)) in"
        }
    }

    @ViewBuilder
    private var summary: some View {
        VStack(spacing: 4) {
            if let first = missingFields.first {
                Text("Set up your profile")
                    .font(.headline)
                Text("Add your \(missingFields.map(\.rawValue).formatted(.list(type: .and)))")
                    .font(.footnote)
                    .foregroundStyle(WatchPalette.textSecondary)
                    .multilineTextAlignment(.center)
                // Drawn as a filled button: a plain NavigationLink in this list row reads as text
                NavigationLink { screen(for: first) } label: {
                    Text("Start")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(WatchPalette.attention))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            } else if !hasResult {
                ProgressView()
            } else if let message = result.message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(WatchPalette.textSecondary)
            } else {
                // Read as one sentence by VoiceOver
                VStack(spacing: 4) {
                    Text(result.caloriesAdjustedPerDay.formatted())
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("calories per day \(profile.calorieAdjustmentMethod.resultCaption)")
                        .font(.footnote)
                        .foregroundStyle(WatchPalette.textSecondary)
                        .multilineTextAlignment(.center)

                    HStack {
                        macro("Protein", grams: result.proteinGrams, colour: WatchPalette.macroProtein)
                        macro("Carbs", grams: result.carbsGrams, colour: WatchPalette.macroCarbs)
                        macro("Fats", grams: result.fatsGrams, colour: WatchPalette.macroFat)
                    }
                    .padding(.top, 4)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "\(result.caloriesAdjustedPerDay.formatted()) calories per day \(profile.calorieAdjustmentMethod.resultCaption). "
                    + "Protein \(result.proteinGrams) grams, carbs \(result.carbsGrams) grams, fats \(result.fatsGrams) grams.")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func row<Destination: View>(_ title: String, value: String, isMissing: Bool = false, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(isMissing ? WatchPalette.attention : WatchPalette.textSecondary)
            }
        }
    }

    private func macro(_ name: String, grams: Int, colour: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(grams)g")
                .font(.headline)
                .foregroundStyle(colour)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(name)
                .font(.caption2)
                .foregroundStyle(WatchPalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
