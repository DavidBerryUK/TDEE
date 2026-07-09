import Testing
@testable import SimpleTest // Adjust this import to match your module name
internal import Foundation

private func format(_ value: Double, _ specifier: String) -> String {
    return String(format: "%\(specifier)f", value)
}

@Suite("Calculation Service BMR Tests")
struct CalculationServiceBMRTests {

    @Test("Calculate BMR with manual body fat percentage")
    func testCalculateBMRWithManualBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 20

        let bmr = CalculationService.calculateBMR(profile: profile)

        // Expected calculation: 76.2 * 60 + 5 * 170 - 18.5 * 30 + 5 * (20/100)
        // = 4572 + 850 - 555 + 1 = 4868
        #expect(bmr == 4868.0, "BMR calculation should include body fat component when method is manualEntry")
    }

    @Test("Calculate BMR with estimate body fat percentage (no body fat component)")
    func testCalculateBMRWithEstimateBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.bodyFatPercentageMethod = .estimate
        profile.bodyFatPercentage = 20 // Should be ignored

        let bmr = CalculationService.calculateBMR(profile: profile)

        // Expected calculation: 76.2 * 60 + 5 * 170 - 18.5 * 30 + 0
        // = 4572 + 850 - 555 = 4867
        #expect(bmr == 4867.0, "BMR calculation should NOT include body fat component when method is estimate")
    }

    @Test("Calculate BMR with omit body fat percentage (no body fat component)")
    func testCalculateBMRWithOmitBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.bodyFatPercentageMethod = .omit
        profile.bodyFatPercentage = 20 // Should be ignored

        let bmr = CalculationService.calculateBMR(profile: profile)

        // Expected calculation: 76.2 * 60 + 5 * 170 - 18.5 * 30 + 0
        // = 4572 + 850 - 555 = 4867
        #expect(bmr == 4867.0, "BMR calculation should NOT include body fat component when method is omit")
    }

    @Test("Calculate BMR for female")
    func testCalculateBMRForFemale() throws {
        let profile = ProfileViewModel()
        profile.gender = .female
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 20

        let bmr = CalculationService.calculateBMR(profile: profile)

        // For female, should return default fallback value (1200.0) since condition is gender == .male
        #expect(bmr == 1200.0, "Female BMR should use default fallback")
    }
}

@Suite("Calculation Service TDEE Tests")
struct CalculationServiceTDEETests {

    @Test("Calculate TDEE with sedentary activity level")
    func testCalculateTDEESedentary() throws {
        let bmr = 1500.0
        let profile = ProfileViewModel()
        profile.activityLevel = .sedentary

        // Test using the approach from current implementation
        let tdee = CalculationService.calculateTdee(bmr: bmr, activityLevel: profile.activityLevel)

        #expect(tdee == 1800.0, "TDEE should be 1500 * 1.2 for sedentary")
    }

    @Test("Calculate TDEE with moderate exercise activity level")
    func testCalculateTDEEModerateExercise() throws {
        let bmr = 1500.0
        let profile = ProfileViewModel()
        profile.activityLevel = .moderateExercise

        let tdee = CalculationService.calculateTdee(bmr: bmr, activityLevel: profile.activityLevel)

        #expect(tdee == 2325.0, "TDEE should be 1500 * 1.55 for moderate exercise")
    }
}

@Suite("Profile ViewModel Calculation Tests")
struct ProfileViewModelCalculationTests {

    @Test("Automatic recalculation on property changes")
    func testAutomaticRecalculation() throws {
        let profile = ProfileViewModel()

        // Set initial values
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.activityLevel = .moderateExercise

        // Trigger calculation manually to get initial state
        profile.calculateAllDerivedValues()

        let initialTDEE = profile.tdee
        let initialMacros = profile.macroTargets

        // Change a property that should trigger recalculation
        profile.weight = 65

        // Verify the change was applied and recalculation happened
        #expect(profile.tdee != initialTDEE, "TDEE should change when weight changes")
        #expect(profile.macroTargets != initialMacros, "Macro targets should change when weight changes")
    }

    @Test("Body fat percentage method correctly affects calculation")
    func testBodyFatMethodAffectsCalculation() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 60

        // Test with manual entry (should include body fat)
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 20

        let bmrWithBodyFat = CalculationService.calculateBMR(profile: profile)

        // Test with estimate (should not include body fat)
        profile.bodyFatPercentageMethod = .estimate

        let bmrWithoutBodyFat = CalculationService.calculateBMR(profile: profile)

        #expect(bmrWithBodyFat != bmrWithoutBodyFat, "BMR should be different when body fat is included vs excluded")
    }
}

@Suite("Calculation Service Validation Tests")
struct CalculationServiceValidationTests {

    @Test("Validate BMR calculation with valid inputs")
    func testValidBMRCalculation() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 60

        let bmr = CalculationService.calculateBMR(profile: profile)

        #expect(bmr > 0, "BMR should be positive for valid inputs")
        #expect(bmr < 5000, "BMR should be reasonable for typical inputs")
    }

    @Test("Validate TDEE calculation with valid inputs")
    func testValidTDEECalculation() throws {
        let bmr = 1500.0
        let profile = ProfileViewModel()
        profile.activityLevel = .sedentary

        let tdee = CalculationService.calculateTdee(bmr: bmr, activityLevel: profile.activityLevel)

        #expect(tdee > bmr, "TDEE should be greater than BMR")
        #expect(tdee > 0, "TDEE should be positive")
    }
}
