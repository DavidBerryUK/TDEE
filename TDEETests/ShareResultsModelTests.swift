import Testing
@testable import TDEE
import Foundation

// MARK: - ShareResultsModel Tests

@Suite("ShareResultsModel Tests")
@MainActor
struct ShareResultsModelTests {

    // MARK: - Gender Formatting Tests

    @Test("Gender Male is formatted correctly")
    func testGenderMaleFormatted() throws {
        let profile = ProfileViewModel()
        profile.gender = .male

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.genderText == "Male", "Male gender should be formatted as 'Male'")
    }

    @Test("Gender Female is formatted correctly")
    func testGenderFemaleFormatted() throws {
        let profile = ProfileViewModel()
        profile.gender = .female

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.genderText == "Female", "Female gender should be formatted as 'Female'")
    }

    // MARK: - Age Formatting Tests

    @Test("Age is formatted with 'years' suffix")
    func testAgeFormatted() throws {
        let profile = ProfileViewModel()
        profile.age = 25

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.ageText == "25 years", "Age should include 'years' suffix")
    }

    // MARK: - Height/Weight Formatting Tests

    @Test("Height is formatted with 'cm' suffix")
    func testHeightFormatted() throws {
        let profile = ProfileViewModel()
        profile.height = 175

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.heightText == "175 cm", "Height should include 'cm' suffix")
    }

    @Test("Weight is formatted with 'kg' suffix")
    func testWeightFormatted() throws {
        let profile = ProfileViewModel()
        profile.weight = 70

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.weightText == "70 kg", "Weight should include 'kg' suffix")
    }

    // MARK: - Activity Level Formatting Tests

    @Test("Activity level description is used")
    func testActivityLevelFormatted() throws {
        let profile = ProfileViewModel()
        profile.activityLevel = .moderateExercise

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.activityLevelText.contains("Moderate"), "Activity level should use description")
    }

    // MARK: - Body Fat Formatting Tests

    @Test("Body fat shows percentage when manual entry with valid value")
    func testBodyFatWithManualEntry() throws {
        let profile = ProfileViewModel()
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 15

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.bodyFatText == "15%", "Body fat should show percentage")
    }

    @Test("Body fat shows N/A when method is omit")
    func testBodyFatWhenOmit() throws {
        let profile = ProfileViewModel()
        profile.bodyFatPercentageMethod = .omit
        profile.bodyFatPercentage = 0

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.bodyFatText == "N/A", "Body fat should be N/A when method is omit")
    }

    @Test("Body fat shows N/A when manual entry but value is 0")
    func testBodyFatWithZeroValue() throws {
        let profile = ProfileViewModel()
        profile.bodyFatPercentageMethod = .manualEntry
        profile.bodyFatPercentage = 0

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.bodyFatText == "N/A", "Body fat should be N/A when value is 0")
    }

    // MARK: - Calorie Adjustment Formatting Tests

    @Test("Calorie adjustment shows method name")
    func testCalorieAdjustmentMethod() throws {
        let profile = ProfileViewModel()
        profile.calorieAdjustmentMethod = .cut

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.calorieAdjustmentText == "Cut", "Calorie adjustment should show method name")
    }

    @Test("Calorie adjustment amount shows with plus sign when positive")
    func testCalorieAdjustmentPositive() throws {
        let profile = ProfileViewModel()
        profile.calorieAdjustmentMethod = .bulk
        profile.calorieAdjustment = 500

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 2500

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.calorieAdjustmentAmountText == "+500 kcal", "Positive adjustment should have + sign")
    }

    @Test("Calorie adjustment amount shows with minus sign when negative")
    func testCalorieAdjustmentNegative() throws {
        let profile = ProfileViewModel()
        profile.calorieAdjustmentMethod = .cut
        profile.calorieAdjustment = -300

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1700

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.calorieAdjustmentAmountText == "-300 kcal", "Negative adjustment should have - sign")
    }

    @Test("Calorie adjustment amount shows 'None' when adjustment is 0")
    func testCalorieAdjustmentZero() throws {
        let profile = ProfileViewModel()
        profile.calorieAdjustmentMethod = .maintain
        profile.calorieAdjustment = 0

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 2000

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.calorieAdjustmentAmountText == "None", "Zero adjustment should show 'None'")
    }

    // MARK: - Macro Split Formatting Tests

    @Test("Macro split method name is used")
    func testMacroSplitMethodName() throws {
        let profile = ProfileViewModel()
        profile.selectedMacroId = FactoryMacroSplits.Id.ketogenic

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result, macroMethodName: "Ketogenic", macroPresetName: "Ketogenic")

        #expect(model.macroSplitMethodText == "Ketogenic", "Macro split method should use preset name")
    }

    @Test("Macro split method falls back to 'Custom' when preset not found")
    func testMacroSplitMethodFallback() throws {
        let profile = ProfileViewModel()
        profile.selectedMacroId = UUID()

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result, macroMethodName: "Custom", macroPresetName: "Custom")

        #expect(model.macroSplitMethodText == "Custom", "Missing preset should fallback to 'Custom'")
    }

    // MARK: - Calculation Output Formatting Tests

    @Test("BMR is formatted with 'kcal/day' suffix")
    func testBMRFormatted() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1850.5
        result.tdee = 2400.5
        result.adjustedCalories = 2200.5

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.bmrText == "1850 kcal/day", "BMR should be formatted with integer and 'kcal/day'")
    }

    @Test("TDEE is formatted with 'kcal/day' suffix")
    func testTDEEFormatted() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1850.5
        result.tdee = 2400.5
        result.adjustedCalories = 2200.5

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.tdeeText == "2400 kcal/day", "TDEE should be formatted with integer and 'kcal/day'")
    }

    @Test("Adjusted calories is formatted with 'kcal/day' suffix")
    func testAdjustedCaloriesFormatted() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1850.5
        result.tdee = 2400.5
        result.adjustedCalories = 2200.5

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.adjustedCaloriesText == "2200 kcal/day", "Adjusted calories should be formatted with integer and 'kcal/day'")
    }

    // MARK: - Macro Targets Formatting Tests

    @Test("Macro targets include protein with grams and percentage")
    func testMacroTargetsProtein() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.proteinGrams = 200
        result.proteinPercent = 40
        result.carbsGrams = 150
        result.carbsPercent = 30
        result.fatsGrams = 66
        result.fatsPercent = 30

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.macroTargetsText.contains("- Protein: 200g"), "Macro targets should include protein in grams")
        #expect(model.macroTargetsText.contains("(40%)"), "Macro targets should include percentage")
    }

    @Test("Macro targets include carbs with grams and percentage")
    func testMacroTargetsCarbs() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.proteinGrams = 200
        result.proteinPercent = 40
        result.carbsGrams = 150
        result.carbsPercent = 30
        result.fatsGrams = 66
        result.fatsPercent = 30

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.macroTargetsText.contains("- Carbs: 150g"), "Macro targets should include carbs in grams")
    }

    @Test("Macro targets include fats with grams and percentage")
    func testMacroTargetsFats() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.proteinGrams = 200
        result.proteinPercent = 40
        result.carbsGrams = 150
        result.carbsPercent = 30
        result.fatsGrams = 66
        result.fatsPercent = 30

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.macroTargetsText.contains("- Fats: 66g"), "Macro targets should include fats in grams")
    }

    // MARK: - Share Text Content Tests

    @Test("shareText contains INPUTS section")
    func testShareTextContainsInputsSection() throws {
        let profile = ProfileViewModel()
        profile.gender = .male

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.shareText.contains("INPUTS:"), "Share text should contain INPUTS section header")
    }

    @Test("shareText contains RESULTS section")
    func testShareTextContainsResultsSection() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.shareText.contains("RESULTS:"), "Share text should contain RESULTS section header")
    }

    @Test("shareText contains MACRO TARGETS section")
    func testShareTextContainsMacroTargetsSection() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.shareText.contains("MACRO TARGETS:"), "Share text should contain MACRO TARGETS section header")
    }

    @Test("shareText contains gender information")
    func testShareTextContainsGender() throws {
        let profile = ProfileViewModel()
        profile.gender = .female

        let result = CalculatorResultViewModel()
        result.bmr = 1500
        result.tdee = 2000
        result.adjustedCalories = 1800

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.shareText.contains("Gender:"), "Share text should contain gender line")
        #expect(model.shareText.contains("Female"), "Share text should contain gender value")
    }

    @Test("shareText contains BMR information")
    func testShareTextContainsBMR() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1850
        result.tdee = 2400
        result.adjustedCalories = 2200

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.shareText.contains("BMR: 1850 kcal/day"), "Share text should contain BMR line")
    }

    @Test("shareText contains TDEE information")
    func testShareTextContainsTDEE() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1850
        result.tdee = 2400
        result.adjustedCalories = 2200

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.shareText.contains("TDEE: 2400 kcal/day"), "Share text should contain TDEE line")
    }

    @Test("shareText contains adjusted calories information")
    func testShareTextContainsAdjustedCalories() throws {
        let profile = ProfileViewModel()

        let result = CalculatorResultViewModel()
        result.bmr = 1850
        result.tdee = 2400
        result.adjustedCalories = 2200

        let model = ShareResultsModel(profile: profile, result: result)

        #expect(model.shareText.contains("Adjusted Calories: 2200 kcal/day"), "Share text should contain adjusted calories line")
    }

    // MARK: - Empty Model Tests

    @Test("Empty model has empty share text")
    func testEmptyModelShareText() throws {
        let model = ShareResultsModel.empty

        #expect(model.shareText.contains("INPUTS:"), "Empty model share text should still have section headers")
        #expect(model.shareText.contains("RESULTS:"), "Empty model share text should still have section headers")
    }
}
