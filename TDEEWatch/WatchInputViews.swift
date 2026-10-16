//
//  WatchInputViews.swift
//  TDEE Watch
//

import SwiftUI

// Weight is stored in kg and height in cm. The watch edits those units directly.
// Ranges match the iPhone wheel pickers.

private enum WatchRanges {
    static let age = Array(16...99)
    static let weightKg = Array(0...250)
    static let heightCm = Array(0...272)
    static let bodyFatInteger = Array(0...99)
    static let bodyFatDecimal = Array(0...9)
    /// Same limits as `CalorieAdjustmentConstants` on the iPhone (that file is iPhone-only).
    static let adjustment = Array(stride(from: 0, through: 1000, by: 25))
}

/// A titled screen holding one wheel picker.
private struct WheelScreen<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        content
            .pickerStyle(.wheel)
            .labelsHidden()
            .navigationTitle(title)
    }
}

struct WatchGenderView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        WheelScreen(title: "Gender") {
            Picker("Gender", selection: $profile.gender) {
                ForEach(Gender.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
        }
    }
}

struct WatchAgeView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        WheelScreen(title: "Age") {
            Picker("Age in years", selection: $profile.age) {
                ForEach(WatchRanges.age, id: \.self) { Text("\($0)").tag($0) }
            }
        }
    }
}

struct WatchWeightView: View {
    @Bindable var profile: ProfileViewModel

    private var kilograms: Binding<Int> {
        Binding(get: { Int(profile.weight.rounded()) }, set: { profile.weight = Double($0) })
    }

    var body: some View {
        WheelScreen(title: "Weight") {
            Picker("Weight in kilograms", selection: kilograms) {
                ForEach(WatchRanges.weightKg, id: \.self) { Text("\($0) kg").tag($0) }
            }
        }
    }
}

struct WatchHeightView: View {
    @Bindable var profile: ProfileViewModel

    private var centimetres: Binding<Int> {
        Binding(get: { Int(profile.height.rounded()) }, set: { profile.height = Double($0) })
    }

    var body: some View {
        WheelScreen(title: "Height") {
            Picker("Height in centimetres", selection: centimetres) {
                ForEach(WatchRanges.heightCm, id: \.self) { Text("\($0) cm").tag($0) }
            }
        }
    }
}

struct WatchActivityLevelView: View {
    @Bindable var profile: ProfileViewModel

    var body: some View {
        WheelScreen(title: "Activity") {
            Picker("Activity level", selection: $profile.activityLevel) {
                ForEach(ActivityLevel.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
        }
    }
}

struct WatchBodyFatView: View {
    @Bindable var profile: ProfileViewModel

    private var tenths: Int { Int((profile.bodyFatPercentage * 10).rounded()) }

    private var wholePart: Binding<Int> {
        Binding(get: { tenths / 10 }, set: { profile.bodyFatPercentage = Double($0 * 10 + tenths % 10) / 10 })
    }

    private var decimalPart: Binding<Int> {
        Binding(get: { tenths % 10 }, set: { profile.bodyFatPercentage = Double(tenths / 10 * 10 + $0) / 10 })
    }

    var body: some View {
        VStack {
            Picker("Method", selection: $profile.bodyFatPercentageMethod) {
                ForEach(BodyFatOption.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.navigationLink)

            if profile.bodyFatPercentageMethod == .manualEntry {
                HStack(spacing: 0) {
                    Picker("Body fat percentage", selection: wholePart) {
                        ForEach(WatchRanges.bodyFatInteger, id: \.self) { Text("\($0)").tag($0) }
                    }
                    Text(".")
                    Picker("Body fat decimal", selection: decimalPart) {
                        ForEach(WatchRanges.bodyFatDecimal, id: \.self) { Text("\($0)").tag($0) }
                    }
                    Text("%")
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
        }
        .navigationTitle("Body Fat")
    }
}

struct WatchCalorieAdjustmentView: View {
    @Bindable var profile: ProfileViewModel

    /// Rounded to the wheel's step so the selection always matches an option.
    private var calories: Binding<Int> {
        Binding(
            get: { Int((profile.calorieAdjustment / 25).rounded()) * 25 },
            set: { profile.calorieAdjustment = Double($0) })
    }

    var body: some View {
        VStack {
            Picker("Method", selection: $profile.calorieAdjustmentMethod) {
                ForEach(CalorieAdjustmentMethod.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.navigationLink)

            if profile.calorieAdjustmentMethod != .maintain {
                Picker("Calories per day", selection: calories) {
                    ForEach(WatchRanges.adjustment, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
        }
        .navigationTitle("Adjust")
    }
}
