import SwiftData
import Foundation

/// Maps between ProfileViewModel and SwiftData Profile entity
@MainActor
enum ProfileMapper {
    /// Copy stored values onto an existing ViewModel.
    /// Never creates a ViewModel: its initializer loads from SwiftData, which would recurse.
    static func apply(_ entity: Profile, to viewModel: ProfileViewModel) {
        viewModel.name = entity.name
        viewModel.gender = entity.gender == 1 ? .female : .male
        viewModel.age = entity.age
        viewModel.height = entity.height
        viewModel.weight = entity.weight
        viewModel.activityLevel = entity.activityLevel
        viewModel.bodyFatPercentageMethod = BodyFatOption(rawValue: entity.bodyFatMethodRaw) ?? .omit
        viewModel.bodyFatPercentage = entity.bodyFatPercentage
        viewModel.calorieAdjustmentMethod = CalorieAdjustmentMethod(rawValue: entity.calorieAdjustmentMethodRaw) ?? .maintain
        viewModel.calorieAdjustment = entity.calorieAdjustment
        viewModel.selectedMacroId = entity.selectedMacroId
    }

    /// Convert ViewModel to entity for saving to SwiftData
    /// When updating an existing profile, pass the existing entity.
    /// When creating a new profile, pass nil and let the repository's createProfile(name:) assign an id.
    static func mapToEntity(_ viewModel: ProfileViewModel, existing: Profile?) -> Profile {
        guard let existingProfile = existing else {
            // Create a new profile with a new UUID
            let profile = Profile(
                name: viewModel.name,
                gender: Int16(viewModel.gender.rawValue),
                age: viewModel.age,
                height: viewModel.height,
                weight: viewModel.weight,
                bodyFatPercentage: viewModel.bodyFatPercentage,
                activityLevel: viewModel.activityLevel,
                bodyFatMethod: viewModel.bodyFatPercentageMethod,
                calorieAdjustmentMethod: viewModel.calorieAdjustmentMethod,
                calorieAdjustment: viewModel.calorieAdjustment,
                selectedMacroId: viewModel.selectedMacroId,
                id: UUID(),
                createdAt: Date(),
                updatedAt: Date()
            )
            return profile
        }
        // Update existing profile
        existingProfile.name = viewModel.name
        existingProfile.gender = Int16(viewModel.gender.rawValue)
        existingProfile.age = viewModel.age
        existingProfile.height = viewModel.height
        existingProfile.weight = viewModel.weight
        existingProfile.activityLevel = viewModel.activityLevel
        existingProfile.bodyFatPercentage = viewModel.bodyFatPercentage
        existingProfile.bodyFatMethodRaw = viewModel.bodyFatPercentageMethod.rawValue
        existingProfile.calorieAdjustmentMethodRaw = viewModel.calorieAdjustmentMethod.rawValue
        existingProfile.calorieAdjustment = viewModel.calorieAdjustment
        existingProfile.selectedMacroId = viewModel.selectedMacroId
        existingProfile.updatedAt = Date()
        return existingProfile
    }
}
