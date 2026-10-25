import Testing
@testable import TDEE
import Foundation

private func format(_ value: Double, _ specifier: String) -> String {
    return String(format: "%\(specifier)f", value)
}

// MARK: - ProfileViewModel Calculation Tests (Mifflin-St Jeor)

@Suite("ProfileViewModel Mifflin-St Jeor BMR Tests")
@MainActor
struct ProfileViewModelMifflinStJeorTests {

    @Test("Calculate BMR for male with manual body fat")
    func testMaleBMRWithManualBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 20

        let bmr = profile.calculateMifflinStJeor()

        // Expected: 10 * 60 + 6.25 * 170 - 5 * 30 + 5 = 600 + 1062.5 - 150 + 5 = 1517.5
        #expect(bmr == 1517.5, "Male BMR should use Mifflin-St Jeor formula with +5 adjustment")
    }

    @Test("Calculate BMR for female with manual body fat")
    func testFemaleBMRWithManualBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .female
        profile.age = 30
        profile.height = 165
        profile.weight = 60
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 25

        let bmr = profile.calculateMifflinStJeor()

        // Expected: 10 * 60 + 6.25 * 165 - 5 * 30 - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
        #expect(bmr == 1320.25, "Female BMR should use Mifflin-St Jeor formula with -161 adjustment")
    }

    @Test("Calculate BMR for male - verify formula components")
    func testMaleBMRCalculation() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 25
        profile.height = 175
        profile.weight = 70

        let bmr = profile.calculateMifflinStJeor()

        // Expected: 10 * 70 + 6.25 * 175 - 5 * 25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
        #expect(bmr == 1673.75, "BMR calculation should match Mifflin-St Jeor formula")
    }

    @Test("Calculate BMR for female - verify formula components")
    func testFemaleBMRCalculation() throws {
        let profile = ProfileViewModel()
        profile.gender = .female
        profile.age = 25
        profile.height = 160
        profile.weight = 55

        let bmr = profile.calculateMifflinStJeor()

        // Expected: 10 * 55 + 6.25 * 160 - 5 * 25 - 161 = 550 + 1000 - 125 - 161 = 1264
        #expect(bmr == 1264.0, "BMR calculation should match Mifflin-St Jeor formula for females")
    }

    @Test("BMR differs between male and female with same stats")
    func testBMRDiffersBetweenGenders() throws {
        let maleProfile = ProfileViewModel()
        maleProfile.gender = .male
        maleProfile.age = 30
        maleProfile.height = 180
        maleProfile.weight = 75

        let femaleProfile = ProfileViewModel()
        femaleProfile.gender = .female
        femaleProfile.age = 30
        femaleProfile.height = 180
        femaleProfile.weight = 75

        let maleBmr = maleProfile.calculateMifflinStJeor()
        let femaleBmr = femaleProfile.calculateMifflinStJeor()

        #expect(maleBmr > femaleBmr, "Male BMR should be higher than female BMR for same stats")
        #expect(maleBmr == 1730.0, "Male BMR should be 1730.0")
        #expect(femaleBmr == 1564.0, "Female BMR should be 1564.0")
    }
}

// MARK: - ProfileViewModel Katch-McArdle Tests

@Suite("ProfileViewModel Katch-McArdle BMR Tests")
@MainActor
struct ProfileViewModelKatchMcArdleTests {

    @Test("Calculate BMR using Katch-McArdle with manual body fat")
    func testKatchMcArdleWithManualBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 180
        profile.weight = 80
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 20

        let bmr = profile.calculateKatchMcArdle()

        // LBM = 80 * (1 - 0.20) = 64
        // BMR = 370 + 21.6 * 64 = 370 + 1382.4 = 1752.4
        #expect(bmr == 1752.4, "Katch-McArdle BMR should use lean body mass formula")
    }

    @Test("Calculate BMR using Katch-McArdle with estimate body fat")
    func testKatchMcArdleWithEstimateBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 180
        profile.weight = 80
        profile.bodyFatPercentageMethod = .estimate

        let bmr = profile.calculateKatchMcArdle()

        // For males: LBM = 0.407 * weight + 0.267 * height - 19.2
        // LBM = 0.407 * 80 + 0.267 * 180 - 19.2 = 32.56 + 48.06 - 19.2 = 61.42
        // BMR = 370 + 21.6 * 61.42 = 370 + 1326.672 = 1696.672
        #expect(abs(bmr - 1696.672) < 0.01, "Katch-McArdle with estimate should use gender-specific LBM formula")
    }

    @Test("Katch-McArdle for female with estimate body fat")
    func testFemaleKatchMcArdle() throws {
        let profile = ProfileViewModel()
        profile.gender = .female
        profile.age = 28
        profile.height = 165
        profile.weight = 65
        profile.bodyFatPercentageMethod = .estimate

        let bmr = profile.calculateKatchMcArdle()

        // For females: LBM = 0.252 * weight + 0.473 * height - 48.3
        // LBM = 0.252 * 65 + 0.473 * 165 - 48.3 = 16.38 + 78.045 - 48.3 = 46.125
        // BMR = 370 + 21.6 * 46.125 = 370 + 996.3 = 1366.3
        #expect(abs(bmr - 1366.3) < 0.1, "Female Katch-McArdle should use female-specific LBM formula")
    }

    @Test("Katch-McArdle with omit body fat method returns 0")
    func testKatchMcArdleWithOmitBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 180
        profile.weight = 80
        profile.bodyFatPercentageMethod = .omit

        let bmr = profile.calculateKatchMcArdle()

        // When omit, LBM returns 0, so BMR = 370 + 21.6 * 0 = 370
        #expect(bmr == 370.0, "Katch-McArdle with omit should return BMR based on 0 LBM")
    }
}

// MARK: - ProfileViewModel TDEE Tests

@Suite("ProfileViewModel TDEE Tests")
@MainActor
struct ProfileViewModelTDEETests {

    @Test("Calculate TDEE with sedentary activity level")
    func testTDEESedentary() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.activityLevel = .sedentary

        // Use Mifflin-St Jeor since no body fat
        let bmr = profile.calculateMifflinStJeor()
        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: profile.activityLevel)

        // Sedentary multiplier is 1.2
        #expect(tdee == bmr * 1.2, "TDEE should be BMR * 1.2 for sedentary")
        #expect(tdee == bmr * 1.2, "TDEE should equal 1800 when BMR is 1500")
    }

    @Test("Calculate TDEE with moderate exercise activity level")
    func testTDEEModerateExercise() throws {
        let bmr = 1500.0
        let activityLevel: ActivityLevel = .moderateExercise

        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: activityLevel)

        // Moderate exercise multiplier is 1.55
        #expect(tdee == 2325.0, "TDEE should be 1500 * 1.55 = 2325 for moderate exercise")
    }

    @Test("TDEE increases with activity level")
    func testTDEEIncreasesWithActivity() throws {
        let bmr = 1500.0

        let sedentaryTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .sedentary)
        let lightTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .lightExercise)
        let moderateTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .moderateExercise)
        let heavyTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .heavyExercise)
        let athleteTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .athlete)

        #expect(sedentaryTdee < lightTdee, "Sedentary TDEE should be less than light")
        #expect(lightTdee < moderateTdee, "Light TDEE should be less than moderate")
        #expect(moderateTdee < heavyTdee, "Moderate TDEE should be less than heavy")
        #expect(heavyTdee < athleteTdee, "Heavy TDEE should be less than athlete")
    }

    @Test("Activity levels are five distinct levels with distinct TDEE outputs")
    func testActivityLevelsAreDistinct() throws {
        // PA-10: the legacy near-duplicates were removed, so every level yields a
        // distinct TDEE.
        let tdees = ActivityLevel.allCases.map { Calculator.adjustForActivityLevel(bmr: 1000, activityLevel: $0) }
        #expect(ActivityLevel.allCases.count == 5, "Exactly five activity levels")
        #expect(Set(tdees).count == tdees.count, "Every level yields a distinct TDEE")
    }
}

// MARK: - ProfileViewModel Integration Tests

@Suite("ProfileViewModel Integration Tests")
@MainActor
struct ProfileViewModelIntegrationTests {

    @Test("Body fat method affects BMR calculation")
    func testBodyFatMethodAffectsCalculation() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 170
        profile.weight = 70

        // Without body fat (Mifflin-St Jeor)
        profile.bodyFatPercentageMethod = .omit
        let bmrWithoutFat = profile.calculateMifflinStJeor()

        // With body fat (Katch-McArdle)
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 20
        let bmrWithFat = profile.calculateKatchMcArdle()

        #expect(bmrWithFat != bmrWithoutFat, "BMR should differ with and without body fat")
    }
}

// MARK: - Unit Tests for Calculation Formulas

@Suite("Formula Verification Tests")
@MainActor
struct FormulaVerificationTests {

    @Test("Mifflin-St Jeor male formula verification")
    func testMifflinStJeorMaleFormula() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 175
        profile.weight = 75

        let bmr = profile.calculateMifflinStJeor()

        // Formula: 10 * weight + 6.25 * height - 5 * age + 5
        // = 10 * 75 + 6.25 * 175 - 5 * 30 + 5
        // = 750 + 1093.75 - 150 + 5
        // = 1698.75
        #expect(bmr == 1698.75, "Mifflin-St Jeor male formula should be exact")
    }

    @Test("Mifflin-St Jeor female formula verification")
    func testMifflinStJeorFemaleFormula() throws {
        let profile = ProfileViewModel()
        profile.gender = .female
        profile.age = 28
        profile.height = 165
        profile.weight = 65

        let bmr = profile.calculateMifflinStJeor()

        // Formula: 10 * weight + 6.25 * height - 5 * age - 161
        // = 10 * 65 + 6.25 * 165 - 5 * 28 - 161
        // = 650 + 1031.25 - 140 - 161
        // = 1380.25
        #expect(bmr == 1380.25, "Mifflin-St Jeor female formula should be exact")
    }

    @Test("Katch-McArdle formula verification")
    func testKatchMcArdleFormula() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 180
        profile.weight = 80
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 25

        let bmr = profile.calculateKatchMcArdle()

        // LBM = weight * (1 - bodyFat/100) = 80 * 0.75 = 60
        // BMR = 370 + 21.6 * LBM = 370 + 1296 = 1666
        #expect(bmr == 1666.0, "Katch-McArdle formula should be exact")
    }

    @Test("TDEE activity multiplier verification")
    func testActivityMultipliers() throws {
        let bmr = 1500.0

        // Test each activity level multiplier
        let sedentaryTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .sedentary)
        #expect(sedentaryTdee == 1800.0, "Sedentary multiplier (1.2) should give 1800")

        let lightTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .lightExercise)
        #expect(lightTdee == 2062.5, "Light exercise multiplier (1.375) should give 2062.5")

        let moderateTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .moderateExercise)
        #expect(moderateTdee == 2325.0, "Moderate exercise multiplier (1.55) should give 2325")

        let heavyTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .heavyExercise)
        #expect(heavyTdee == 2587.5, "Heavy exercise multiplier (1.725) should give 2587.5")

        let athleteTdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: .athlete)
        #expect(athleteTdee == 2850.0, "Athlete multiplier (1.9) should give 2850")
    }

    @Test("Edge case: Zero values handled gracefully")
    func testZeroValues() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 0
        profile.height = 0
        profile.weight = 0

        // Should not crash, though values may be unusual
        let bmr = profile.calculateMifflinStJeor()
        // Formula: 10*0 + 6.25*0 - 5*0 + 5 = 5 for males
        #expect(bmr == 5.0, "BMR should be 5 for zero inputs with male gender")
    }

    @Test("Edge case: High body fat percentage")
    func testHighBodyFat() throws {
        let profile = ProfileViewModel()
        profile.gender = .male
        profile.age = 30
        profile.height = 180
        profile.weight = 100
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 40

        let bmr = profile.calculateKatchMcArdle()

        // LBM = 100 * 0.6 = 60
        // BMR = 370 + 21.6 * 60 = 1666
        #expect(bmr == 1666.0, "High body fat calculation should be correct")
    }
}

// MARK: - ProfileViewModel Validation Tests

@Suite("ProfileViewModel Validation Tests")
@MainActor
struct ProfileViewModelValidationTests {

    @Test("validateForCalculation returns nil when all fields valid")
    func testValidProfileReturnsNil() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70

        let result = profile.validateForCalculation()
        #expect(result == nil, "Valid profile should return nil")
    }

    @Test("validateForCalculation returns error when age is 0")
    func testZeroAgeReturnsError() throws {
        let profile = ProfileViewModel()
        profile.age = 0
        profile.height = 170
        profile.weight = 70

        let result = profile.validateForCalculation()
        #expect(result != nil, "Zero age should return error")
        #expect(result?.contains("Age") == true, "Error should mention Age")
    }

    @Test("validateForCalculation returns error when height is 0")
    func testZeroHeightReturnsError() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 0
        profile.weight = 70

        let result = profile.validateForCalculation()
        #expect(result != nil, "Zero height should return error")
        #expect(result?.contains("Height") == true, "Error should mention Height")
    }

    @Test("validateForCalculation returns error when weight is 0")
    func testZeroWeightReturnsError() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 0

        let result = profile.validateForCalculation()
        #expect(result != nil, "Zero weight should return error")
        #expect(result?.contains("Weight") == true, "Error should mention Weight")
    }

    @Test("validateForCalculation returns all missing fields in error")
    func testMultipleMissingFields() throws {
        let profile = ProfileViewModel()
        profile.age = 0
        profile.height = 0
        profile.weight = 0

        let result = profile.validateForCalculation()
        #expect(result != nil, "Multiple zeros should return error")
        #expect(result?.contains("Age") == true, "Error should mention Age")
        #expect(result?.contains("Height") == true, "Error should mention Height")
        #expect(result?.contains("Weight") == true, "Error should mention Weight")
    }

    @Test("Body fat validation does not trigger when method is omit")
    func testBodyFatNotValidatedWhenOmit() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.bodyFatPercentageMethod = .omit
        profile.bodyFatPercentage = 1  // Even invalid value should not trigger

        let result = profile.validateForCalculation()
        #expect(result == nil, "Body fat should not be validated when method is .omit")
    }

    @Test("Body fat validation does not trigger when method is estimate")
    func testBodyFatNotValidatedWhenEstimate() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.bodyFatPercentageMethod = .estimate
        profile.bodyFatPercentage = 1  // Even invalid value should not trigger

        let result = profile.validateForCalculation()
        #expect(result == nil, "Body fat should not be validated when method is .estimate")
    }

    @Test("Body fat validation triggers when method is manualEntry with invalid value")
    func testBodyFatValidationWithManualEntryInvalid() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 1  // Below minimum

        let result = profile.validateForCalculation()
        #expect(result != nil, "Invalid body fat should return error")
        #expect(result?.contains("Body Fat Percentage") == true, "Error should mention Body Fat Percentage")
    }

    @Test("Body fat validation passes with valid manual entry (5%)")
    func testBodyFatValidMinimum() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 5  // At minimum boundary

        let result = profile.validateForCalculation()
        #expect(result == nil, "Body fat at 5% should be valid")
    }

    @Test("Body fat validation passes with valid manual entry (50%)")
    func testBodyFatValidMaximum() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 50  // At maximum boundary

        let result = profile.validateForCalculation()
        #expect(result == nil, "Body fat at 50% should be valid")
    }

    @Test("Body fat validation fails below minimum (4%)")
    func testBodyFatBelowMinimum() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 4  // Below minimum

        let result = profile.validateForCalculation()
        #expect(result != nil, "Body fat below 5% should be invalid")
        #expect(result?.contains("Body Fat Percentage") == true, "Error should mention Body Fat Percentage")
    }

    @Test("Body fat validation fails above maximum (51%)")
    func testBodyFatAboveMaximum() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 70
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 51  // Above maximum

        let result = profile.validateForCalculation()
        #expect(result != nil, "Body fat above 50% should be invalid")
        #expect(result?.contains("Body Fat Percentage") == true, "Error should mention Body Fat Percentage")
    }

    @Test("Body fat validation range boundary values")
    func testBodyFatRangeBoundaries() throws {
        // Test just inside boundaries - should pass
        let profile1 = ProfileViewModel()
        profile1.age = 30
        profile1.height = 170
        profile1.weight = 70
        profile1.bodyFatPercentageMethod = .manualEntry
        profile1.bodyFatPercentage = 5.1
        #expect(profile1.validateForCalculation() == nil, "5.1% should be valid")

        let profile2 = ProfileViewModel()
        profile2.age = 30
        profile2.height = 170
        profile2.weight = 70
        profile2.bodyFatPercentageMethod = .manualEntry
        profile2.bodyFatPercentage = 49.9
        #expect(profile2.validateForCalculation() == nil, "49.9% should be valid")

        // Test just outside boundaries - should fail
        let profile3 = ProfileViewModel()
        profile3.age = 30
        profile3.height = 170
        profile3.weight = 70
        profile3.bodyFatPercentageMethod = .manualEntry
        profile3.bodyFatPercentage = 4.9
        #expect(profile3.validateForCalculation() != nil, "4.9% should be invalid")

        let profile4 = ProfileViewModel()
        profile4.age = 30
        profile4.height = 170
        profile4.weight = 70
        profile4.bodyFatPercentageMethod = .manualEntry
        profile4.bodyFatPercentage = 50.1
        #expect(profile4.validateForCalculation() != nil, "50.1% should be invalid")
    }
}
