//
//  WatchCalorieAdjustmentView.swift
//  TDEE Watch
//
//

import SwiftUI

struct WatchCalorieAdjustmentView: View {
    @Bindable var profile: ProfileViewModel

    /// Rounded to the wheel's step so the selection always matches an option.
    private var calories: Binding<Int> {
        Binding(
            get: { Int((profile.calorieAdjustment / 25).rounded()) * 25 },
            set: {
                // Clamp to valid range and ensure step alignment
                let clamped = min(max($0, WatchRanges.adjustment.first ?? 0), WatchRanges.adjustment.last ?? 1000)
                let stepped = Int((Double(clamped) / 25).rounded()) * 25
                profile.calorieAdjustment = Double(stepped)
            }
        )
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

#Preview() {
    WatchCalorieAdjustmentView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
