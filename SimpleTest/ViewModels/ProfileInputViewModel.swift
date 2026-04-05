import Foundation
import Combine

final class ProfileInputViewModel: ObservableObject {
    // custom properties
    private var isUpdatingExpansion = false

    @Published var gender: enumGender
    @Published var genderIsExpanded: Bool

    @Published var age: Int
    @Published var ageIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .age, newValue: ageIsExpanded)
        }
    }

    @Published var weightUom: enumOptionWeight = enumOptionWeight.kilograms
    @Published var weight: Double
    @Published var weightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .weight, newValue: weightIsExpanded)
        }
    }

    @Published var heightUom: enumOptionLength = enumOptionLength.centimeters
    @Published var height: Double
    @Published var heightIsExpanded: Bool {
        didSet {
            enforceExclusiveExpansion(changed: .height, newValue: heightIsExpanded)
        }
    }

    @Published var activityLevel: Int
    @Published var activityLevelIsExpanded: Bool

    @Published var bodyFatPercentage: Int
    @Published var bodyFatPercentageIsExpanded: Bool

    private enum EnumExpansionField { case age, weight, height }

    private func enforceExclusiveExpansion(changed: EnumExpansionField, newValue: Bool) {
        if isUpdatingExpansion { return }
        guard newValue == true else { return }
        isUpdatingExpansion = true
        switch changed {
        case .age:
            if weightIsExpanded { weightIsExpanded = false }
            if heightIsExpanded { heightIsExpanded = false }
        case .weight:
            if ageIsExpanded { ageIsExpanded = false }
            if heightIsExpanded { heightIsExpanded = false }
        case .height:
            if ageIsExpanded { ageIsExpanded = false }
            if weightIsExpanded { weightIsExpanded = false }
        }
        isUpdatingExpansion = false
    }

    init(gender: enumGender = enumGender.male, age: Int = 18, weight: Double = 70, height: Double = 170, activityLevel: Int = 0) {
        self.gender = gender
        self.age = age
        self.weight = weight
        self.height = height
        self.bodyFatPercentage = 15
        self.activityLevel = activityLevel

        // Initialize expansion flags without triggering observers
        self.isUpdatingExpansion = true
        self.ageIsExpanded = false
        self.genderIsExpanded = false
        self.weightIsExpanded = false
        self.heightIsExpanded = false
        self.activityLevelIsExpanded = false
        self.bodyFatPercentageIsExpanded = false
        self.isUpdatingExpansion = false
    }
    
    func collapseAll() {
        self.ageIsExpanded = false;
        self.genderIsExpanded = false
        self.weightIsExpanded = false
        self.heightIsExpanded = false;
        self.activityLevelIsExpanded = false
        self.bodyFatPercentageIsExpanded = false
    }
}
