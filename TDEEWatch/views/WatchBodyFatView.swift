//
//  WatchBodyFatView.swift
//  TDEE Watch
//
//

import SwiftUI

struct WatchBodyFatView: View {
    @Bindable var profile: ProfileViewModel

    /// Store the body fat value in tenths (e.g., 157 for 15.7%) to avoid floating point issues
    private var bodyFatTenths: Binding<Int> {
        Binding(
            get: { Int((profile.bodyFatPercentage * 10).rounded()) },
            set: { profile.bodyFatPercentage = Double($0) / 10 }
        )
    }

    /// Extract the whole part from tenths (e.g., 157 -> 15)
    private var wholePart: Binding<Int> {
        Binding(
            get: { bodyFatTenths.wrappedValue / 10 },
            set: { bodyFatTenths.wrappedValue = $0 * 10 + (bodyFatTenths.wrappedValue % 10) }
        )
    }

    /// Extract the decimal part from tenths (e.g., 157 -> 7)
    private var decimalPart: Binding<Int> {
        Binding(
            get: { bodyFatTenths.wrappedValue % 10 },
            set: { bodyFatTenths.wrappedValue = (bodyFatTenths.wrappedValue / 10 * 10) + $0 }
        )
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

#Preview() {
    WatchBodyFatView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
