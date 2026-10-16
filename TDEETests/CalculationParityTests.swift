import Testing
@testable import TDEE
import Foundation

// The watch app compiles the same TDEEShared calculation code as the iPhone app, so these
// fixed inputs must always give the same numbers. The first case matches what the watch
// simulator showed for the default profile (2,594 kcal; 259g / 194g / 86g).

@Suite("Calculation parity (iPhone and watch share this code)")
@MainActor
struct CalculationParityTests {

    /// A profile on its own in-memory store, with every input set explicitly.
    private func makeProfile(bodyFat: BodyFatOption, bodyFatPercentage: Double = 0) -> ProfileViewModel {
        let repository = SwiftDataContainer(isInMemory: true).profileRepository
        let profile = ProfileViewModel(profileRepository: repository)
        profile.gender = .male
        profile.age = 25
        profile.weight = 70
        profile.height = 175
        profile.activityLevel = .moderateExercise
        profile.bodyFatPercentageMethod = bodyFat
        profile.bodyFatPercentage = bodyFatPercentage
        profile.calorieAdjustmentMethod = .maintain
        profile.calorieAdjustment = 0
        profile.protein = 40
        profile.carbs = 30
        profile.fats = 30
        return profile
    }

    @Test("Mifflin-St Jeor: 25 y male, 70 kg, 175 cm, moderate exercise gives 2,594 kcal")
    func mifflinStJeor() async {
        let result = await Calculator.calculate(person: makeProfile(bodyFat: .omit))

        #expect(result.message == nil)
        #expect(result.caloriesAdjustedPerDay == 2594)
        #expect(result.caloriesAdjustedPerWeek == 18158)
        #expect(result.proteinGrams == 259)
        #expect(result.carbsGrams == 194)
        #expect(result.fatsGrams == 86)
    }

    @Test("Katch-McArdle: the same person at 15% body fat gives 2,565 kcal")
    func katchMcArdle() async {
        let result = await Calculator.calculate(person: makeProfile(bodyFat: .manualEntry, bodyFatPercentage: 15))

        #expect(result.message == nil)
        #expect(result.caloriesAdjustedPerDay == 2565)
        #expect(result.caloriesAdjustedPerWeek == 17955)
    }
}
