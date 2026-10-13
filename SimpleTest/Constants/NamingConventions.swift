//
//  NamingConventions.swift
//  SimpleTest
//
//  Created by David Berry on 15/04/2026.
//

/// Swift Naming Conventions for SimpleTest
///
/// This document defines the naming conventions used throughout the codebase.
/// All new code should follow these conventions.
///
/// ## Overview
///
/// SimpleTest follows Apple's Swift API Design Guidelines:
/// - **camelCase** for variables, functions, and methods
/// - **PascalCase** for types (structs, classes, enums, protocols)
/// - **SCREAMING_SNAKE_CASE** for constants when not part of a type
///
/// ## Detailed Guidelines
///
/// ### 1. Variables and Properties
/// - Use camelCase
/// - Start with lowercase letter
/// - Examples:
///   ```swift
///   let userName: String
///   var userAge: Int
///   let maxCalorieAdjustment: Double
///   ```
///
/// ### 2. Functions and Methods
/// - Use camelCase
/// - Start with lowercase letter
/// - Descriptive names that explain what the function does
/// - Examples:
///   ```swift
///   func calculateBMR() -> Double
///   func updateProfile(with data: ProfileData)
///   static func validateRange(_ value: Double) -> Bool
///   ```
///
/// ### 3. Types (Structs, Classes, Enums)
/// - Use PascalCase
/// - Start with uppercase letter
/// - Examples:
///   ```swift
///   struct UserProfile
///   class CalculationService
///   enum Gender
///   ```
///
/// ### 4. Constants
/// - Within types: use `static let` with camelCase
/// - Standalone: use SCREAMING_SNAKE_CASE
/// - Examples:
///   ```swift
///   struct MathConstants {
///       static let pi = 3.14159
///   }
///   let MAX_VALUE = 1000
///   ```
///
/// ### 5. Protocols
/// - Use PascalCase
/// - Named after capabilities (ending in "able" or "able" is common)
/// - Examples:
///   ```swift
///   protocol Equatable
///   protocol Comparable
///   protocol DataSerializable
///   ```
///
/// ### 6. Enum Cases
/// - Use camelCase (not PascalCase)
/// - Examples:
///   ```swift
///   enum CalorieAdjustmentMethod {
///       case cut
///       case bulk
///       case maintain
///   }
///   ```
///
/// ### 7. File Names
/// - Match the primary type name in the file
/// - Use PascalCase
/// - Examples:
///   ```swift
///   // File: ProfileViewModel.swift
///   class ProfileViewModel { ... }
///
///   // File: CalculationService.swift
///   struct CalculationService { ... }
///   ```
///
/// ## Naming Pattern Checklist
///
/// Before committing code, verify:
/// - [ ] Variables/properties use camelCase
/// - [ ] Types use PascalCase
/// - [ ] Enum cases use camelCase
/// - [ ] Function names are descriptive verbs
/// - [ ] Boolean properties use is/prefix (e.g., `isEnabled`, `hasData`)
/// - [ ] Constants are properly scoped
///
/// ## Examples: Correct vs Incorrect
///
/// ### Correct:
/// ```swift
/// let maxWeight: Double = 300.0
/// let minCalorieAdjustment: Int = 0
/// func calculateTDEE() -> Double
/// struct UserProfile { ... }
/// enum Gender { case male, female, other }
/// ```
///
/// ### Incorrect:
/// ```swift
/// let max_weight: Double = 300.0         // snake_case - wrong
/// let MaxWeight: Double = 300.0          // PascalCase for var - wrong
/// func CalculateTDEE() -> Double         // PascalCase for func - wrong
/// struct userProfile { ... }             // camelCase for struct - wrong
/// enum Gender { case MALE, FEMALE }      // SCREAMING_CASE for cases - wrong
/// ```

/// Minimum calorie adjustment value (0 calories/day)
let CalorieAdjustmentMin: Double = 0

/// Maximum calorie adjustment value (1000 calories/day)
let CalorieAdjustmentMax: Double = 1000

/// Slider step increment (25 calories/day)
let CalorieAdjustmentStep: Double = 25
