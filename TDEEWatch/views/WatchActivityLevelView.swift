//
//  WatchActivityLevelView.swift
//  TDEE Watch
//

import SwiftUI

/// Five distinct activity levels, each with a short description, picked from a list.
struct WatchActivityLevelView: View {
    @Bindable var profile: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(WatchRanges.activityLevels, id: \.self) { level in
            Button {
                profile.activityLevel = level
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(level.displayName)
                        Text(level.watchDescription)
                            .font(.caption2)
                            .foregroundStyle(WatchPalette.textSecondary)
                    }
                    Spacer()
                    if level == profile.activityLevel.watchLevel {
                        Image(systemName: "checkmark")
                            .foregroundStyle(WatchPalette.selection)
                    }
                }
            }
            .accessibilityAddTraits(level == profile.activityLevel.watchLevel ? .isSelected : [])
        }
        .navigationTitle("Activity")
    }
}

extension ActivityLevel {
    /// The level the watch shows for this value. Older near-duplicates map to the
    /// level with the same multiplier, so a profile saved on the iPhone still shows a tick.
    var watchLevel: ActivityLevel {
        switch self {
        case .light: return .lightExercise
        case .moderate: return .moderateExercise
        case .active: return .heavyExercise
        case .veryActive: return .athlete
        default: return self
        }
    }

    /// A short line under each level on the watch.
    var watchDescription: String {
        switch watchLevel {
        case .sedentary: return "Little or no exercise"
        case .lightExercise: return "1–2 days a week"
        case .moderateExercise: return "3–5 days a week"
        case .heavyExercise: return "6–7 days a week"
        case .athlete: return "Twice a day"
        default: return ""
        }
    }
}

#Preview() {
    WatchActivityLevelView(profile: ProfileViewModel(profileRepository: SwiftDataContainer.shared.profileRepository))
}
