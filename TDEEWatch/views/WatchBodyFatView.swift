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
            set: {
                // 50.x is over the limit, so clamp to the accepted range
                let percent = Double($0) / 10
                profile.bodyFatPercentage = min(max(percent, WatchRanges.bodyFatPercent.lowerBound), WatchRanges.bodyFatPercent.upperBound)
            }
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
            Picker("Body fat", selection: $profile.bodyFatPercentageMethod) {
                ForEach(BodyFatOption.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.navigationLink)

            if profile.bodyFatPercentageMethod != .manualEntry {
                Text(profile.bodyFatPercentageMethod.watchCaption)
                    .font(.footnote)
                    .foregroundStyle(WatchPalette.textSecondary)
                    .multilineTextAlignment(.center)
            }

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
        // Manual entry needs a value the calculation accepts; a new profile has 0%
        .onChange(of: profile.bodyFatPercentageMethod, initial: true) { _, method in
            if method == .manualEntry, !WatchRanges.bodyFatPercent.contains(profile.bodyFatPercentage) {
                profile.bodyFatPercentage = WatchRanges.startingBodyFatPercent
            }
        }
    }
}

extension BodyFatOption {
    /// Explains what each choice does, shown under the picker on the watch.
    var watchCaption: String {
        switch self {
        case .omit: return "Calories are worked out without body fat."
        case .estimate: return "Estimated from your gender, weight and height."
        case .manualEntry: return "Enter your own measurement."
        }
    }
}

#Preview() {
    WatchBodyFatView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
