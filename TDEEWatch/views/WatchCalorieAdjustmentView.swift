//
//  WatchCalorieAdjustmentView.swift
//  TDEE Watch
//

import SwiftUI

/// The goal: maintain, or cut / bulk by a number of kcal a day.
struct WatchCalorieAdjustmentView: View {
    @Bindable var profile: ProfileViewModel

    /// Rounded to the wheel's step and kept in range so the selection always matches an option.
    private var calories: Binding<Int> {
        Binding(
            get: {
                let stepped = Int((profile.calorieAdjustment / 25).rounded()) * 25
                return min(max(stepped, WatchRanges.adjustment.first!), WatchRanges.adjustment.last!)
            },
            set: { profile.calorieAdjustment = Double($0) }
        )
    }

    var body: some View {
        VStack {
            Picker("Goal", selection: $profile.calorieAdjustmentMethod) {
                ForEach(CalorieAdjustmentMethod.allCases, id: \.self) { Text($0.goalName).tag($0) }
            }
            .pickerStyle(.navigationLink)

            if profile.calorieAdjustmentMethod != .maintain {
                Picker("Calories per day", selection: calories) {
                    ForEach(WatchRanges.adjustment, id: \.self) { Text("\($0) kcal").tag($0) }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            } else {
                Text("Eat what you burn each day.")
                    .font(.footnote)
                    .foregroundStyle(WatchPalette.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("Goal")
        // Cut or bulk by 0 would be the same as Maintain, so start the wheel somewhere useful
        .onChange(of: profile.calorieAdjustmentMethod, initial: true) { _, method in
            if method != .maintain, profile.calorieAdjustment < Double(WatchRanges.adjustment.first!) {
                profile.calorieAdjustment = WatchRanges.startingAdjustment
            }
        }
    }
}

extension CalorieAdjustmentMethod {
    /// Plain-language goal names for the watch.
    var goalName: String {
        switch self {
        case .cut: return "Lose weight"
        case .maintain: return "Maintain"
        case .bulk: return "Gain weight"
        }
    }

    /// Completes "calories per day …" under the result.
    var resultCaption: String {
        switch self {
        case .cut: return "to lose weight"
        case .maintain: return "to maintain"
        case .bulk: return "to gain weight"
        }
    }
}

#Preview() {
    WatchCalorieAdjustmentView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
