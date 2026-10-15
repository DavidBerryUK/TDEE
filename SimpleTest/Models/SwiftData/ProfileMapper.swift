import SwiftData
import Foundation

/// Maps between ProfileViewModel and SwiftData Profile entity
@MainActor
enum ProfileMapper {
    /// Convert entity to ViewModel for reading from SwiftData
    static func mapToViewModel(_ entity: Profile) -> ProfileViewModel {
        // Create a new ViewModel with default values
        let viewModel = ProfileViewModel()
        switch entity.gender {
        case 0: viewModel.gender = .male
        case 1: viewModel.gender = .female
        default: viewModel.gender = .male
        }
        viewModel.age = Int(entity.age)
        viewModel.height = entity.height
        viewModel.weight = entity.weight
        viewModel.activityLevel = entity.activityLevel
        viewModel.bodyFatPercentage = entity.bodyFatPercentage
        viewModel.bodyFatPercentageMethod = .omit  // Default since we don't store this
        // Note: Derived values (tdee, macroTargets) are recalculated automatically by ProfileViewModel
        return viewModel
    }

    /// Convert ViewModel to entity for saving to SwiftData
    /// When updating an existing profile, pass the existing entity.
    /// When creating a new profile, pass nil and use the repository's createDefaultProfile or insert a new entity.
    static func mapToEntity(_ viewModel: ProfileViewModel, existing: Profile?) -> Profile {
        guard let existingProfile = existing else {
            // Create a new profile with a new UUID
            let profile = Profile(
                gender: Int16(viewModel.gender.rawValue),
                age: viewModel.age,
                height: viewModel.height,
                weight: viewModel.weight,
                bodyFatPercentage: viewModel.bodyFatPercentage,
                activityLevel: viewModel.activityLevel,
                id: UUID(),
                createdAt: Date(),
                updatedAt: Date()
            )
            return profile
        }
        // Update existing profile
        existingProfile.gender = Int16(viewModel.gender.rawValue)
        existingProfile.age = viewModel.age
        existingProfile.height = viewModel.height
        existingProfile.weight = viewModel.weight
        existingProfile.activityLevel = viewModel.activityLevel
        existingProfile.bodyFatPercentage = viewModel.bodyFatPercentage
        existingProfile.updatedAt = Date()
        return existingProfile
    }
}
