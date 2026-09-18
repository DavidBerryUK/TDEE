//
//  SimpleTestUITests_Gender.swift
//  SimpleTestUITests
//
//  Created by David Berry on 17/09/2026.
//

import XCTest

final class SimpleTestUITests_Gender: XCTestCase {

    let utils = SimpleTestUITestUtils.self

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    @MainActor
    func testGenderSelectorExists() throws {
        let app = XCUIApplication()
        app.launch()

        let genderSection = app.otherElements["sectionGender"]
        genderSection.tap()

        let segmentedControl = utils.findSegmentedControl(in: app)
        if let segmentedControl = segmentedControl {
            XCTAssertTrue(utils.waitForElement(segmentedControl), "Gender segmented control should exist")

            XCTAssertTrue(segmentedControl.buttons["Male"].exists)
            XCTAssertTrue(segmentedControl.buttons["Female"].exists)
        } else {
            XCTFail("Gender segmented control not found in accessibility hierarchy")
        }
    }

    @MainActor
    func testGenderSummaryUpdatesAfterSelectionChange() throws {
        let app = XCUIApplication()
        app.launch()

        // Expand the Gender section
        let genderSection = app.otherElements["sectionGender"]
        genderSection.tap()

        // Verify initial selection is Male
        let segmentedControl = utils.findSegmentedControl(in: app)
        XCTAssertTrue(utils.waitForElement(segmentedControl!), "Gender segmented control should exist")
        XCTAssertTrue(segmentedControl!.buttons["Male"].isSelected, "Male should be selected by default")

        // Select Female
        segmentedControl!.buttons["Female"].tap()

        // Collapse the section
        genderSection.tap()

        // Wait for the UI to settle after collapsing
        Thread.sleep(forTimeInterval: 1.0)

        // Debug: dump section properties to understand accessibility hierarchy
        print("=== Section Gender Debug Info ===")
        print("Section identifier: \(genderSection.identifier)")
        print("Section value: \(String(describing: genderSection.value))")
        print("Section label: \(genderSection.label)")
        print("Section enabled: \(genderSection.isEnabled)")
        print("Section frame: \(genderSection.frame)")

        // Try accessing the value directly and log what we get
        let sectionValueRaw = genderSection.value
        print("Section value raw type: \(type(of: sectionValueRaw))")
        print("Section value raw description: \(String(describing: sectionValueRaw))")

        // Also check if we can find any Text elements that are children of the section
        let sectionChildren = genderSection.descendants(matching: .any)
        print("Section children count: \(sectionChildren.count)")
        for i in 0..<min(sectionChildren.count, 20) {
            let child = sectionChildren.element(boundBy: i)
            print("Child \(i): type=\(child.elementType), label='\(child.label)', identifier='\(child.identifier)'")
        }

        // Find all StaticText elements within the section
        let allStaticTexts = genderSection.descendants(matching: .staticText)
        print("\n=== All StaticText elements in section ===")
        print("Found \(allStaticTexts.count) StaticText elements")
        for i in 0..<min(allStaticTexts.count, 20) {
            let textElement = allStaticTexts.element(boundBy: i)
            let value = textElement.value as? String ?? "nil"
            print("StaticText[\(i)]: label='\(textElement.label)', value='\(value)', identifier='\(textElement.identifier)'")
            print("  - elementType: \(textElement.elementType), exists: \(textElement.exists)")
        }

        // Also check if the section's value property contains the gender
        if let sectionVal = genderSection.value as? String {
            print("\nSection value (as String): '\(sectionVal)'")
        } else {
            print("\nSection value is not a String: \(String(describing: genderSection.value))")
        }

        // Check if we can find text by iterating through children
        print("\n=== Iterating through all children ===")
        let allChildren = genderSection.descendants(matching: .any)
        for i in 0..<min(allChildren.count, 30) {
            let child = allChildren.element(boundBy: i)
            let label = child.label.isEmpty ? "(empty)" : child.label
            let value = child.value as? String ?? "nil"
            print("Child[\(i)]: type=\(child.elementType), label='\(label)', value='\(value)'")
        }

        // Find the "Gender value" text element by its accessibilityLabel
        let genderValueText = genderSection.descendants(matching: .staticText)["Gender value"]
        print("\n=== Target 'Gender value' element ===")
        print("Gender value text exists: \(genderValueText.exists)")
        print("Gender value text label: '\(genderValueText.label)'")
        print("Gender value text identifier: '\(genderValueText.identifier)'")
        print("Gender value text value: \(String(describing: genderValueText.value))")

        // Check if value property contains the gender
        if let genderValue = genderValueText.value as? String {
            print("Gender value (as String): '\(genderValue)'")
            XCTAssertTrue(genderValue == "Female", "Gender summary should display 'Female' after selection, got '\(genderValue)'")
        } else {
            XCTFail("Gender value text value is not a String: \(String(describing: genderValueText.value))")
        }

        // Expand the section again
        genderSection.tap()

        // Verify Female is still selected in the editor
        XCTAssertTrue(segmentedControl!.buttons["Female"].isSelected, "Female should remain selected after re-expanding")

        // Select Male again
        segmentedControl!.buttons["Male"].tap()

        // Collapse the section
        genderSection.tap()

        // Wait for the UI to settle after collapsing
        Thread.sleep(forTimeInterval: 1.0)

        // Verify the summary now shows Male
        print("=== Section Gender Debug Info (after switching to Male) ===")
        print("Section value: \(String(describing: genderSection.value))")

        // Find the "Gender value" text element again
        let genderValueTextMale = genderSection.descendants(matching: .staticText)["Gender value"]
        print("\n=== Target 'Gender value' element (after switching to Male) ===")
        print("Gender value text label: '\(genderValueTextMale.label)'")
        print("Gender value text identifier: '\(genderValueTextMale.identifier)'")
        print("Gender value text value: \(String(describing: genderValueTextMale.value))")

        if let genderValue = genderValueTextMale.value as? String {
            print("Gender value (as String): '\(genderValue)'")
            XCTAssertTrue(genderValue == "Male", "Gender summary should display 'Male' after selection, got '\(genderValue)'")
        } else {
            XCTFail("Gender value text value is not a String: \(String(describing: genderValueTextMale.value))")
        }

        // Expand the section again
        genderSection.tap()

        // Verify Male is still selected in the editor
        XCTAssertTrue(segmentedControl!.buttons["Male"].isSelected, "Male should remain selected after re-expanding")
    }
}
