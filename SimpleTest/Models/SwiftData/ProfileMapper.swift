import SwiftData
import Foundation

/// Maps between ProfileViewModel and SwiftData Profile entity
enum ProfileMapper {
    /// Convert entity to ViewModel for reading from SwiftData
    static func mapToViewModel(_ entity: Profile) -> ProfileViewModel {
        let viewModel = ProfileViewModel()
        // Set the ID via the initializer since swiftDataId is private
        // We'll just set it after initialization
        viewModel.gender = Gender(rawValue: entity.gender) ?? .male
        viewModel.age = Int(entity.age)
        viewModel.height = entity.height
        viewModel.weight = entity.weight
        viewModel.activityLevel = ActivityLevel(rawValue: entity.activityLevel) ?? .sedentary
        viewModel.bodyFatPercentage = entity.bodyFatPercentage ?? 0.0
        viewModel.bodyFatPercentageMethod = BodyFatOption(rawValue: entity.bodyFatMethod ?? 0) ?? .omit
        // Note: Derived values (tdee, macroTargets) are recalculated automatically by ProfileViewModel
        return viewModel
    }

    /// Convert ViewModel to entity for saving to SwiftData
    static func mapToEntity(_ viewModel: ProfileViewModel, existing: Profile?) -> Profile {
        let profile = existing ?? Profile()
        // We can't directly set swiftDataId since it's private - this is handled in the save operation
        profile.gender = Int16(viewModel.gender.rawValue)
        profile.age = Int16(viewModel.age)
        profile.height = viewModel.height
        profile.weight = viewModel.weight
        profile.activityLevel = Int16(viewModel.activityLevel.rawValue)
        profile.bodyFatPercentage = viewModel.bodyFatPercentage > 0 ? viewModel.bodyFatPercentage : nil
        profile.bodyFatMethod = Int16(viewModel.bodyFatPercentageMethod.rawValue)
        profile.updatedAt = Date()
        // createdAt is preserved from existing entity, set on first creation
        if existing == nil {
            profile.createdAt = Date()
        }
        return profile
    }
}