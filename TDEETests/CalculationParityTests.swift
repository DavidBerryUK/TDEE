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

    // MARK: - Adjustment & recalculation safety net (live path)
    //
    // These pin the behaviours the live UI path depends on so the dead
    // refreshResults()/tdee/macroTargets pipeline can be deleted without
    // silently changing results (PA-29 + the live equivalent of the old
    // dead-pipeline testAutomaticRecalculation).

    @Test("Cut: a 500 kcal cut lowers the daily target to 2,094 kcal")
    func cutAdjustment() async {
        let profile = makeProfile(bodyFat: .omit)
        profile.calorieAdjustmentMethod = .cut
        profile.calorieAdjustment = 500

        let result = await Calculator.calculate(person: profile)

        #expect(result.message == nil)
        // BMR 1673.75 * 1.55 = 2594.3125; minus 500 = 2094.3125 -> Int 2094
        #expect(result.caloriesAdjustedPerDay == 2094)
        #expect(result.caloriesAdjustedPerWeek == 14658)
        // macros computed from 2094 kcal at the profile's 40/30/30 split
        #expect(result.proteinGrams == 209)
        #expect(result.carbsGrams == 157)
        #expect(result.fatsGrams == 69)
    }

    @Test("Bulk: a 500 kcal bulk raises the daily target to 3,094 kcal")
    func bulkAdjustment() async {
        let profile = makeProfile(bodyFat: .omit)
        profile.calorieAdjustmentMethod = .bulk
        profile.calorieAdjustment = 500

        let result = await Calculator.calculate(person: profile)

        #expect(result.message == nil)
        // 2594.3125 + 500 = 3094.3125 -> Int 3094
        #expect(result.caloriesAdjustedPerDay == 3094)
        #expect(result.caloriesAdjustedPerWeek == 21658)
        #expect(result.proteinGrams == 309)
        #expect(result.carbsGrams == 232)
        #expect(result.fatsGrams == 103)
    }

    @Test("Cut: a 500 kcal cut reads a minus in the share text (PA-27)")
    func cutAdjustmentShareSign() async {
        let profile = makeProfile(bodyFat: .omit)
        profile.calorieAdjustmentMethod = .cut
        profile.calorieAdjustment = 500

        let result = await Calculator.calculate(person: profile)
        let model = ShareResultsModel(profile: profile, result: result)

        #expect(result.message == nil)
        // BMR 1673.75 * 1.55 = 2594.3125; minus 500 = 2094.3125 -> Int 2094
        #expect(result.caloriesAdjustedPerDay == 2094)
        // Sign comes from the method's prefix, not the non-negative magnitude (PA-27)
        #expect(model.calorieAdjustmentAmountText == "-500 kcal")
    }

    @Test("Bulk: a 500 kcal bulk reads a plus in the share text (PA-27)")
    func bulkAdjustmentShareSign() async {
        let profile = makeProfile(bodyFat: .omit)
        profile.calorieAdjustmentMethod = .bulk
        profile.calorieAdjustment = 500

        let result = await Calculator.calculate(person: profile)
        let model = ShareResultsModel(profile: profile, result: result)

        #expect(result.message == nil)
        // 2594.3125 + 500 = 3094.3125 -> Int 3094
        #expect(result.caloriesAdjustedPerDay == 3094)
        // Sign comes from the method's prefix, not the non-negative magnitude (PA-27)
        #expect(model.calorieAdjustmentAmountText == "+500 kcal")
    }

    @Test("Recalculation on the live path: changing weight changes the result")
    func recalculationOnChange() async {
        let profile = makeProfile(bodyFat: .omit)
        let before = await Calculator.calculate(person: profile)

        profile.weight = 75
        let after = await Calculator.calculate(person: profile)

        #expect(before.message == nil, "before should be valid")
        #expect(after.message == nil, "after should be valid")
        // 70 kg -> 2594; 75 kg -> BMR 1723.75 * 1.55 = 2671.8125 -> Int 2671
        #expect(before.caloriesAdjustedPerDay == 2594)
        #expect(after.caloriesAdjustedPerDay == 2671)
        #expect(after.caloriesAdjustedPerDay != before.caloriesAdjustedPerDay,
               "Changing weight should change the calculated result on the live path")
    }

    @Test("Zero guard: a cut deeper than TDEE clamps to 0 kcal and 0 grams")
    func zeroGuard() async {
        let profile = makeProfile(bodyFat: .omit)
        profile.calorieAdjustmentMethod = .cut
        profile.calorieAdjustment = 10000

        let result = await Calculator.calculate(person: profile)

        #expect(result.message == nil)
        // adjustCalories clamps max(0, 2594.3125 - 10000) to 0
        #expect(result.caloriesAdjustedPerDay == 0)
        #expect(result.caloriesAdjustedPerWeek == 0)
        #expect(result.proteinGrams == 0)
        #expect(result.carbsGrams == 0)
        #expect(result.fatsGrams == 0)
    }
}
