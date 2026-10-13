import XCTest
@testable import SimpleTest

/// Unit tests for MacroSplitOptionModel
final class MacroSplitOptionModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitDefaultValues() {
        let model = MacroSplitOptionModel()

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 30)
        XCTAssertEqual(model.fats, 30)
        XCTAssertEqual(model.ordinal, -1)
        XCTAssertFalse(model.isSelected)
        XCTAssertFalse(model.id == UUID()) // ID should be generated
    }

    func testInitCustomValues() {
        let customID = UUID()
        let model = MacroSplitOptionModel(
            id: customID,
            name: "Test",
            protein: 50,
            carbs: 30,
            fats: 20,
            ordinal: 1
        )

        XCTAssertEqual(model.id, customID)
        XCTAssertEqual(model.name, "Test")
        XCTAssertEqual(model.protein, 50)
        XCTAssertEqual(model.carbs, 30)
        XCTAssertEqual(model.fats, 20)
        XCTAssertEqual(model.ordinal, 1)
        XCTAssertFalse(model.isSelected)
    }

    func testInitWithSelected() {
        let model = MacroSplitOptionModel(isSelected: true)

        XCTAssertTrue(model.isSelected)

        let model2 = MacroSplitOptionModel(isSelected: false)
        XCTAssertFalse(model2.isSelected)
    }

    func testInitNormalizationWhenTotalOver100() {
        // 50 + 30 + 30 = 110, overflow = -10
        // Each gets -10: 40, 20, 20
        let model = MacroSplitOptionModel(protein: 50, carbs: 30, fats: 30)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 20)
        XCTAssertEqual(model.fats, 20)
    }

    func testInitNormalizationWhenTotalUnder100() {
        // 30 + 20 + 20 = 70, overflow = 30
        // Each gets +30: 60, 50, 50
        let model = MacroSplitOptionModel(protein: 30, carbs: 20, fats: 20)

        XCTAssertEqual(model.protein, 60)
        XCTAssertEqual(model.carbs, 50)
        XCTAssertEqual(model.fats, 50)
    }

    func testInitNormalizationWhenTotalIs100() {
        // 40 + 30 + 30 = 100, overflow = 0
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 30)
        XCTAssertEqual(model.fats, 30)
    }

    // MARK: - snapToStep Tests

    func testSnapToStepWithDoubleInput() {
        XCTAssertEqual(MacroSplitOptionModel.stepSize, 5)

        // Test snapping down
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(4.9), 0)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(5.0), 5)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(7.4), 5)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(7.5), 5) // 7.5/5 = 1.5, Int(1.5) = 1, 1*5 = 5
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(9.9), 5)

        // Test snapping to exact multiples
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(10.0), 10)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(14.9), 10)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(15.0), 15)

        // Test negative values (should clamp to 0)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(-1.0), 0)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(-5.0), 0)
    }

    func testSnapToStepWithIntInput() {
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(4), 0)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(5), 5)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(7), 5)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(9), 5)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(10), 10)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(14), 10)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(15), 15)
    }

    func testSnapToStepClampingTo100() {
        // Values above 100 should be clamped
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(100.0), 100)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(101.0), 100)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(104.9), 100)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(105.0), 100) // 105/5 = 21, 21*5 = 105, then clamped to 100

        // Negative values clamped to 0
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(-5.0), 0)
        XCTAssertEqual(MacroSplitOptionModel.snapToStep(-100.0), 0)
    }

    // MARK: - updateFromUiProtein Tests

    func testUpdateFromUiProteinNoChange() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting the same value should exit early
        model.updateFromUiProtein(to: 40.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 30)
        XCTAssertEqual(model.fats, 30)
    }

    func testUpdateFromUiProteinWithSnap() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 42 should snap to 40
        model.updateFromUiProtein(to: 42.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 30) // 30 + 0 = 30 (no change needed)
        XCTAssertEqual(model.fats, 30)
    }

    func testUpdateFromUiProteinIncreasesProtein() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 50: overflow = 100 - (50 + 30 + 30) = -10
        // carbs = snapToStep(30 + -10) = snapToStep(20) = 20
        // overflow = 100 - (50 + 20 + 30) = 0 (no fats adjustment needed)
        model.updateFromUiProtein(to: 50.0)

        XCTAssertEqual(model.protein, 50)
        XCTAssertEqual(model.carbs, 20)
        XCTAssertEqual(model.fats, 30)
    }

    func testUpdateFromUiProteinIncreasesProteinWithDoubleAdjustment() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 37, fats: 23)

        // Setting 55: overflow = 100 - (55 + 37 + 23) = -15
        // carbs = snapToStep(37 + -15) = snapToStep(22) = 20
        // overflow = 100 - (55 + 20 + 23) = 2
        // fats = snapToStep(23 + 2) = snapToStep(25) = 25
        model.updateFromUiProtein(to: 55.0)

        XCTAssertEqual(model.protein, 55)
        XCTAssertEqual(model.carbs, 20)
        XCTAssertEqual(model.fats, 25)
    }

    func testUpdateFromUiProteinDecreasesProtein() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 30: overflow = 100 - (30 + 30 + 30) = 10
        // carbs = snapToStep(30 + 10) = snapToStep(40) = 40
        // overflow = 100 - (30 + 40 + 30) = 0
        model.updateFromUiProtein(to: 30.0)

        XCTAssertEqual(model.protein, 30)
        XCTAssertEqual(model.carbs, 40)
        XCTAssertEqual(model.fats, 30)
    }

    func testUpdateFromUiProteinDecreasesProteinWithDoubleAdjustment() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 38, fats: 22)

        // Setting 35: overflow = 100 - (35 + 38 + 22) = 5
        // carbs = snapToStep(38 + 5) = snapToStep(43) = 40
        // overflow = 100 - (35 + 40 + 22) = 3
        // fats = snapToStep(22 + 3) = snapToStep(25) = 25
        model.updateFromUiProtein(to: 35.0)

        XCTAssertEqual(model.protein, 35)
        XCTAssertEqual(model.carbs, 40)
        XCTAssertEqual(model.fats, 25)
    }

    func testUpdateFromUiProteinEdgeCaseZero() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 0: overflow = 100 - (0 + 30 + 30) = 40
        // carbs = snapToStep(30 + 40) = snapToStep(70) = 70
        // overflow = 100 - (0 + 70 + 30) = 0
        model.updateFromUiProtein(to: 0.0)

        XCTAssertEqual(model.protein, 0)
        XCTAssertEqual(model.carbs, 70)
        XCTAssertEqual(model.fats, 30)
    }

    func testUpdateFromUiProteinEdgeCase100() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 100: overflow = 100 - (100 + 30 + 30) = -60
        // carbs = snapToStep(30 + -60) = snapToStep(-30) = 0
        // overflow = 100 - (100 + 0 + 30) = -30
        // fats = snapToStep(30 + -30) = snapToStep(0) = 0
        model.updateFromUiProtein(to: 100.0)

        XCTAssertEqual(model.protein, 100)
        XCTAssertEqual(model.carbs, 0)
        XCTAssertEqual(model.fats, 0)
    }

    // MARK: - updateFromUiCarbs Tests

    func testUpdateFromUiCarbsNoChange() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        model.updateFromUiCarbs(to: 30.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 30)
        XCTAssertEqual(model.fats, 30)
    }

    func testUpdateFromUiCarbsIncreasesCarbs() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 40: overflow = 100 - (40 + 40 + 30) = -10
        // fats = snapToStep(30 + -10) = snapToStep(20) = 20
        // overflow = 100 - (40 + 40 + 20) = 0
        model.updateFromUiCarbs(to: 40.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 40)
        XCTAssertEqual(model.fats, 20)
    }

    func testUpdateFromUiCarbsIncreasesCarbsWithDoubleAdjustment() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 37, fats: 23)

        // Setting 50: overflow = 100 - (40 + 50 + 23) = -13
        // fats = snapToStep(23 + -13) = snapToStep(10) = 10
        // overflow = 100 - (40 + 50 + 10) = 0
        model.updateFromUiCarbs(to: 50.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 50)
        XCTAssertEqual(model.fats, 10)
    }

    func testUpdateFromUiCarbsDecreasesCarbs() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 20: overflow = 100 - (40 + 20 + 30) = 10
        // fats = snapToStep(30 + 10) = snapToStep(40) = 40
        // overflow = 100 - (40 + 20 + 40) = 0
        model.updateFromUiCarbs(to: 20.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 20)
        XCTAssertEqual(model.fats, 40)
    }

    func testUpdateFromUiCarbsEdgeCaseZero() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 0: overflow = 100 - (40 + 0 + 30) = 30
        // fats = snapToStep(30 + 30) = snapToStep(60) = 60
        // overflow = 100 - (40 + 0 + 60) = 0
        model.updateFromUiCarbs(to: 0.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 0)
        XCTAssertEqual(model.fats, 60)
    }

    func testUpdateFromUiCarbsEdgeCase100() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 100: overflow = 100 - (40 + 100 + 30) = -70
        // fats = snapToStep(30 + -70) = snapToStep(-40) = 0
        // overflow = 100 - (40 + 100 + 0) = -40
        // protein = snapToStep(40 + -40) = snapToStep(0) = 0
        model.updateFromUiCarbs(to: 100.0)

        XCTAssertEqual(model.protein, 0)
        XCTAssertEqual(model.carbs, 100)
        XCTAssertEqual(model.fats, 0)
    }

    // MARK: - updateFromUiFats Tests

    func testUpdateFromUiFatsNoChange() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        model.updateFromUiFats(to: 30.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 30)
        XCTAssertEqual(model.fats, 30)
    }

    func testUpdateFromUiFatsIncreasesFats() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 40: overflow = 100 - (40 + 30 + 40) = -10
        // carbs = snapToStep(30 + -10) = snapToStep(20) = 20
        // overflow = 100 - (40 + 20 + 40) = 0
        model.updateFromUiFats(to: 40.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 20)
        XCTAssertEqual(model.fats, 40)
    }

    func testUpdateFromUiFatsIncreasesFatsWithDoubleAdjustment() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 37, fats: 23)

        // Setting 35: overflow = 100 - (40 + 37 + 35) = -12
        // carbs = snapToStep(37 + -12) = snapToStep(25) = 25
        // overflow = 100 - (40 + 25 + 35) = 0
        model.updateFromUiFats(to: 35.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 25)
        XCTAssertEqual(model.fats, 35)
    }

    func testUpdateFromUiFatsDecreasesFats() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 20: overflow = 100 - (40 + 30 + 20) = 10
        // carbs = snapToStep(30 + 10) = snapToStep(40) = 40
        // overflow = 100 - (40 + 40 + 20) = 0
        model.updateFromUiFats(to: 20.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 40)
        XCTAssertEqual(model.fats, 20)
    }

    func testUpdateFromUiFatsEdgeCaseZero() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 0: overflow = 100 - (40 + 30 + 0) = 30
        // carbs = snapToStep(30 + 30) = snapToStep(60) = 60
        // overflow = 100 - (40 + 60 + 0) = 0
        model.updateFromUiFats(to: 0.0)

        XCTAssertEqual(model.protein, 40)
        XCTAssertEqual(model.carbs, 60)
        XCTAssertEqual(model.fats, 0)
    }

    func testUpdateFromUiFatsEdgeCase100() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Setting 100: overflow = 100 - (40 + 30 + 100) = -70
        // carbs = snapToStep(30 + -70) = snapToStep(-40) = 0
        // overflow = 100 - (40 + 0 + 100) = -40
        // protein = snapToStep(40 + -40) = snapToStep(0) = 0
        model.updateFromUiFats(to: 100.0)

        XCTAssertEqual(model.protein, 0)
        XCTAssertEqual(model.carbs, 0)
        XCTAssertEqual(model.fats, 100)
    }

    // MARK: - Hashable Tests

    func testHashableUsesID() {
        let model1 = MacroSplitOptionModel()
        let model2 = MacroSplitOptionModel(id: model1.id, protein: 50, carbs: 50, fats: 0)

        // Same ID means equal
        XCTAssertEqual(model1, model2)
        XCTAssertEqual(model1.hashValue, model2.hashValue)
    }

    func testHashableDifferentIDs() {
        let model1 = MacroSplitOptionModel()
        let model2 = MacroSplitOptionModel()

        // Different IDs means not equal
        XCTAssertNotEqual(model1, model2)
        XCTAssertNotEqual(model1.hashValue, model2.hashValue)
    }

    // MARK: - Total Always Equals 100 Tests

    func testProteinUpdateMaintainsTotal100() {
        let model = MacroSplitOptionModel()

        for protein in [0, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 100] {
            model.updateFromUiProtein(to: Double(protein))

            let total = model.protein + model.carbs + model.fats
            XCTAssertEqual(total, 100, "Total should be 100 when protein is \(protein), got \(total)")
        }
    }

    func testCarbsUpdateMaintainsTotal100() {
        let model = MacroSplitOptionModel()

        for carbs in [0, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 100] {
            model.updateFromUiCarbs(to: Double(carbs))

            let total = model.protein + model.carbs + model.fats
            XCTAssertEqual(total, 100, "Total should be 100 when carbs is \(carbs), got \(total)")
        }
    }

    func testFatsUpdateMaintainsTotal100() {
        let model = MacroSplitOptionModel()

        for fats in [0, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 100] {
            model.updateFromUiFats(to: Double(fats))

            let total = model.protein + model.carbs + model.fats
            XCTAssertEqual(total, 100, "Total should be 100 when fats is \(fats), got \(total)")
        }
    }

    // MARK: - Sequential Updates Tests

    func testSequentialProteinThenCarbsUpdates() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // First update protein to 50
        model.updateFromUiProtein(to: 50.0)
        XCTAssertEqual(model.protein, 50)
        // carbs = 30 + -10 = 20, no adjustment needed for fats
        XCTAssertEqual(model.carbs, 20)
        XCTAssertEqual(model.fats, 30)

        // Then update carbs to 40
        model.updateFromUiCarbs(to: 40.0)
        XCTAssertEqual(model.carbs, 40)
        // protein = 50, carbs = 40, fats = 30 -> total = 120, overflow = -20
        // fats = 30 + -20 = 10
        XCTAssertEqual(model.fats, 10)
        // protein adjustment
        // overflow = 100 - (50 + 40 + 10) = 0, no protein adjustment
        XCTAssertEqual(model.protein, 50)
    }

    func testSequentialUpdatesMaintainValues() {
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // Make multiple sequential changes
        model.updateFromUiProtein(to: 35.0) // protein = 35
        model.updateFromUiCarbs(to: 45.0)   // carbs = 45
        model.updateFromUiFats(to: 20.0)    // fats = 20

        // Check final state
        XCTAssertEqual(model.protein, 35)
        XCTAssertEqual(model.carbs, 45)
        XCTAssertEqual(model.fats, 20)
        XCTAssertEqual(model.protein + model.carbs + model.fats, 100)
    }

    // MARK: - Value Step Constraint Tests

    func testAllValuesAreMultiplesOf5() {
        let model = MacroSplitOptionModel()

        // Test many random values
        let testValues = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]

        for protein in testValues {
            model.updateFromUiProtein(to: Double(protein))
            XCTAssertFalse(model.protein % 5 != 0, "Protein \(model.protein) should be multiple of 5")
            XCTAssertFalse(model.carbs % 5 != 0, "Carbs \(model.carbs) should be multiple of 5")
            XCTAssertFalse(model.fats % 5 != 0, "Fats \(model.fats) should be multiple of 5")
        }
    }

    func testSnappingBehavior() {
        // Values that should snap down
        let model = MacroSplitOptionModel(protein: 40, carbs: 30, fats: 30)

        // 42 -> 40 (snap down)
        model.updateFromUiProtein(to: 42.0)
        XCTAssertEqual(model.protein, 40)

        // 43 -> 40 (snap down)
        model.updateFromUiProtein(to: 43.0)
        XCTAssertEqual(model.protein, 40)

        // 44 -> 40 (snap down)
        model.updateFromUiProtein(to: 44.0)
        XCTAssertEqual(model.protein, 40)

        // 45 -> 45 (exact multiple)
        model.updateFromUiProtein(to: 45.0)
        XCTAssertEqual(model.protein, 45)

        // 46 -> 45 (snap down)
        model.updateFromUiProtein(to: 46.0)
        XCTAssertEqual(model.protein, 45)

        // 47 -> 45 (snap down)
        model.updateFromUiProtein(to: 47.0)
        XCTAssertEqual(model.protein, 45)

        // 48 -> 45 (snap down)
        model.updateFromUiProtein(to: 48.0)
        XCTAssertEqual(model.protein, 45)

        // 49 -> 45 (snap down)
        model.updateFromUiProtein(to: 49.0)
        XCTAssertEqual(model.protein, 45)
    }
}
