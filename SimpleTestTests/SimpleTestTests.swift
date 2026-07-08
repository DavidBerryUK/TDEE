import Testing
@testable import SimpleTest // Adjust this import to match your module name

private func format(_ value: Double, _ specifier: String) -> String {
    return String(format: "%\(specifier)f", value)
}

@Suite("Calculator Validation Tests")
struct CalculatorValidationTests {

    @Test("Validate missing age")
    func testMissingAge() throws {
        let profile = ProfileViewModel()
        profile.age = 0
        profile.height = 170
        profile.weight = 60

        if let errorMessage = profile.validateForCalculation() {
            #expect(errorMessage == "Following fields are mandatory: Age", "Validation should identify missing age")
        } else {
            #expect(false, "Expected a validation error for missing age")
        }
    }

    @Test("Validate missing height")
    func testMissingHeight() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 0
        profile.weight = 60
        
        if let errorMessage = profile.validateForCalculation() {
            #expect(errorMessage == "Following fields are mandatory: Height", "Validation should identify missing height")
        } else {
            #expect(false, "Expected a validation error for missing height")
        }
    }

    @Test("Validate missing weight")
    func testMissingWeight() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 0
        
        if let errorMessage = profile.validateForCalculation() {
            #expect(errorMessage == "Following fields are mandatory: Weight", "Validation should identify missing weight")
        } else {
            #expect(false, "Expected a validation error for missing weight")
        }
    }

}

@Suite("Calculator Mifflin-St. Jeor BMR Calculation Tests")
struct CalculatorMifflinStJeorTests {

    @Test("Calculate Mifflin-St. Jeor for male")
    func testMifflinStJeorMale() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.gender = .male
        
        var logger = AuditLogger(enabled: false)
        let bmr = profile.calculateMifflinStJeor(logger: logger)
        
        #expect(format(bmr, ".2f") == "1537.80", "Incorrect Mifflin-St. Jeor BMR for male")
    }

    @Test("Calculate Mifflin-St. Jeor for female")
    func testMifflinStJeorFemale() throws {
        let profile = ProfileViewModel()
        profile.age = 30
        profile.height = 170
        profile.weight = 60
        profile.gender = .female
        
        var logger = AuditLogger(enabled: false)
        let bmr = profile.calculateMifflinStJeor(logger: logger)
        
        #expect(format(bmr, ".2f") == "1385.90", "Incorrect Mifflin-St. Jeor BMR for female")
    }

}

@Suite("Calculator Katch-McArdle BMR Calculation Tests")
struct CalculatorKatchMcArdleTests {

    @Test("Calculate Katch-McArdle for known LBM")
    func testKatchMcArdle() throws {
        let profile = ProfileViewModel()
        profile.weight = 60
        profile.bodyFatPercentage = 20
        var logger = AuditLogger(enabled: false)
        
        let bmr = profile.calculateKatchMcArdle(logger: logger)
        
        #expect(format(bmr, ".2f") == "1392.00", "Incorrect Katch-McArdle BMR")
    }

}

@Suite("Calculator TDEE Adjustment Tests")
struct CalculatorTdeeAdjustmentTests {

    @Test("Adjust TDEE for Sedentary activity level")
    func testSedentaryActivityLevel() throws {
        let bmr = 1500.0
        let activityLevel = ActivityLevel.sedentary
        var logger = AuditLogger(enabled: false)
        
        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: activityLevel, logger: logger)
        
        #expect(format(tdee, ".2f") == "1800.00", "Incorrect TDEE for Sedentary activity level")
    }

    @Test("Adjust TDEE for Light Exercise activity level")
    func testLightExerciseActivityLevel() throws {
        let bmr = 1500.0
        let activityLevel = enumActivityLevel.lightExercise
        var logger = AuditLogger(enabled: false)
        
        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: activityLevel, logger: logger)
        
        #expect(format(tdee, ".2f") == "2062.50", "Incorrect TDEE for Light Exercise activity level")
    }

    @Test("Adjust TDEE for Moderate Exercise activity level")
    func testModerateExerciseActivityLevel() throws {
        let bmr = 1500.0
        let activityLevel = enumActivityLevel.moderateExercise
        var logger = AuditLogger(enabled: false)
        
        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: activityLevel, logger: logger)
        
        #expect(format(tdee, ".2f") == "2325.00", "Incorrect TDEE for Moderate Exercise activity level")
    }

    @Test("Adjust TDEE for Heavy Exercise activity level")
    func testHeavyExerciseActivityLevel() throws {
        let bmr = 1500.0
        let activityLevel = enumActivityLevel.heavyExercise
        var logger = AuditLogger(enabled: false)
        
        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: activityLevel, logger: logger)
        
        #expect(format(tdee, ".2f") == "2587.50", "Incorrect TDEE for Heavy Exercise activity level")
    }

    @Test("Adjust TDEE for Athlete activity level")
    func testAthleteActivityLevel() throws {
        let bmr = 1500.0
        let activityLevel = enumActivityLevel.athlete
        var logger = AuditLogger(enabled: false)
        
        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: activityLevel, logger: logger)
        
        #expect(format(tdee, ".2f") == "2850.00", "Incorrect TDEE for Athlete activity level")
    }

}

@Suite("Calculator Calorie Adjustment Tests")
struct CalculatorCalorieAdjustmentTests {

    @Test("Maintain calorie adjustment")
    func testMaintainCalories() async throws {
        let tdee = 2000.0
        let profile = ProfileViewModel()
        profile.calorieAdjustmentMethod = .maintain
        
        var logger = AuditLogger(enabled: false)
        let adjustedCalories = profile.adjustCalories(base: tdee, logger: logger)
        
        #expect(format(adjustedCalories, ".2f") == "2000.00", "Incorrect calorie adjustment for maintain")
    }

    @Test("Bulk calorie adjustment")
    func testBulkCalories() async throws {
        let tdee = 2000.0
        let profile = ProfileViewModel()
        profile.calorieAdjustmentMethod = .bulk
        profile.calorieAdjustment = 500
        
        var logger = AuditLogger(enabled: false)
        let adjustedCalories = profile.adjustCalories(base: tdee, logger: logger)
        
        #expect(format(adjustedCalories, ".2f") == "2500.00", "Incorrect calorie adjustment for bulk")
    }

    @Test("Cut calorie adjustment")
    func testCutCalories() async throws {
        let tdee = 2000.0
        let profile = ProfileViewModel()
        profile.calorieAdjustmentMethod = .cut
        profile.calorieAdjustment = 500
        
        var logger = AuditLogger(enabled: false)
        let adjustedCalories = profile.adjustCalories(base: tdee, logger: logger)
        
        #expect(format(adjustedCalories, ".2f") == "1500.00", "Incorrect calorie adjustment for cut")
    }

}

@Suite("Calculator Macro Calculation Tests")
struct CalculatorMacroCalculationTests {

    @Test("Calculate Macros with adjusted calories")
    func testCalculateMacros() async throws {
        let profile = ProfileViewModel()
        profile.weight = 60
        profile.activityLevel = .moderateExercise
        profile.bodyFatPercentageMethod = .estimate
        
        var logger = AuditLogger(enabled: false)
        
        // Calculate BMR and TDEE
        let bmr = profile.calculateKatchMcArdle(logger: logger)
        let tdee = Calculator.adjustForActivityLevel(bmr: bmr, activityLevel: profile.activityLevel, logger: logger)
        let adjustedCalories = profile.adjustCalories(base: tdee, logger: logger)
        
        // Create result view model
        let result = CalculatorResultViewModel()
        result.updateTdee(adjustedCalories: adjustedCalories)
        
        // Calculate macros
        profile.calculateMacros(result: result)
        
        // Expected values based on the provided formula
        #expect(format(Double(result.proteinGrams), ".0f") == "40.0", "Incorrect protein grams")
        #expect(format(Double(result.carbsGrams), ".0f") == "450.0", "Incorrect carbs grams")
        #expect(format(Double(result.fatsGrams), ".0f") == "278.0", "Incorrect fats grams")
    }

}
