import Foundation
import Observation

/// State management for user profile metrics.
///
/// This ViewModel serves as the single source of truth for all user profile data and derived calculations.
/// It manages the raw input values and persists them automatically; results are derived on demand
/// by the live Calculator path.
///
/// ## Key Features
/// - Automatic persistence via throttled saves when inputs change
/// - Clean separation between input data and derived calculations
/// - Comprehensive validation and error handling
/// - Environment-specific defaults via AppConfig (simulator vs. device)
/// - SwiftData persistence integration
@Observable
@MainActor
class ProfileViewModel {
    // MARK: - Persistence Properties

    private let profileRepository: ProfileRepository
    @ObservationIgnored
    nonisolated(unsafe) private var saveTask: Task<Void, Never>?  // For throttled saves
    private let saveDelay: TimeInterval = 1.0  // Wait 1 second after last change
    private var swiftDataId: UUID?  // Track the SwiftData entity ID
    private var isLoading = false  // Suppress saves while restoring stored values

    /// The id of the SwiftData profile this view model is currently bound to.
    /// Defaults to a throwaway value; `load()` / `switchProfile(to:)` re-point it.
    var profileId: UUID = UUID()
    /// The human-readable name of the current profile (e.g. "Main").
    var name: String = ProfileRepository.mainProfileName

    // MARK: - Macro Collection (Injected via Environment)
    /// The global macro options collection - injected via environment
    var macroCollection: MacroSplitOptionsModelCollection?

    // MARK: - State Properties (Input/Raw Data)

    /// User's gender, used in BMR calculation formulas
    var gender: Gender = AppConfig.shared.profileDefaults.gender {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// User's age in years
    var age: Int = AppConfig.shared.profileDefaults.age {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// Unit of measure for weight (kilograms or pounds)
    var weightUom: OptionWeight = OptionWeight.kilograms
    /// User's weight in the current unit of measure
    var weight: Double = AppConfig.shared.profileDefaults.weight {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// Unit of measure for height (centimeters or inches)
    var heightUom: OptionLength = OptionLength.centimeters
    /// User's height in the current unit of measure
    var height: Double = AppConfig.shared.profileDefaults.height {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// User's activity level for TDEE calculation
    var activityLevel: ActivityLevel = AppConfig.shared.profileDefaults.activityLevel {
        didSet {
            triggerSave()  // Throttled save
        }
    }

    // Body Fat Management (Retained pattern)
    /// Method used to determine body fat percentage
    var bodyFatPercentageMethod: BodyFatOption = AppConfig.shared.profileDefaults.bodyFatPercentageMethod {
        didSet {
            bodyFatPercentageShowManualEntry = bodyFatPercentageMethod == .manualEntry
            triggerSave()  // Throttled save
        }
    }
    /// User's body fat percentage
    var bodyFatPercentage: Double = AppConfig.shared.profileDefaults.bodyFatPercentage {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// Whether to show the manual entry field for body fat
    var bodyFatPercentageShowManualEntry: Bool

    // Calorie Adjustment (Retained pattern)
    /// Method for adjusting daily calorie intake
    var calorieAdjustmentMethod: CalorieAdjustmentMethod = AppConfig.shared.profileDefaults.calorieAdjustmentMethod {
        didSet {
            calorieAdjustmentShowSliders = calorieAdjustmentMethod != .maintain
            triggerSave()  // Throttled save
        }
    }
    /// Amount of calories to adjust up or down
    var calorieAdjustment : Double {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// Whether to show the calorie adjustment slider controls
    var calorieAdjustmentShowSliders : Bool

    // Macro Split (Retained pattern)
    /// Protein percentage target
    var protein: Int = 40 {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// Carbs percentage target
    var carbs: Int = 30 {
        didSet {
            triggerSave()  // Throttled save
        }
    }
    /// Fats percentage target
    var fats: Int = 30 {
        didSet {
            triggerSave()  // Throttled save
        }
    }

    // MARK: - Macro Selection (Added for story-013 alignment)
    /// The UUID of the currently selected macro split option
    var selectedMacroId: UUID = FactoryMacroSplits.Id.balanced {
        didSet {
            // When selection changes, sync the macro percentages from the selected preset
            syncSelectedMacro()
            triggerSave()  // Throttled save
        }
    }

    //*******************************
    // Initializer                  *
    //*******************************
    /// Creates a new ProfileViewModel with dependency injection for persistence
    /// - Parameters:
    ///   - profileRepository: The repository for profile persistence
    ///   - macroCollection: Optional macro collection (will be injected from environment when available)
    init(profileRepository: ProfileRepository, macroCollection: MacroSplitOptionsModelCollection? = nil) {
        self.profileRepository = profileRepository
        self.macroCollection = macroCollection
        self.bodyFatPercentageShowManualEntry = false
        self.calorieAdjustment = 0
        self.calorieAdjustmentShowSliders = false
        // protein/carbs/fats keep their declared defaults: assigning them here runs didSet and schedules a save

        // Load from SwiftData on init (if profile exists)
        loadFromSwiftData()
    }

    /// Creates a new ProfileViewModel with default values (for backward compatibility)
    convenience init() {
        self.init(profileRepository: SwiftDataContainer.shared.profileRepository, macroCollection: nil)
    }

    /// Load profile data from SwiftData
    private func loadFromSwiftData() {
        Task { await load() }
    }

    /// Restore the Main profile, if any. Does not trigger a save.
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let profile = try await profileRepository.fetchMainProfile() {
                ProfileMapper.apply(profile, to: self)
                self.profileId = profile.id
                self.swiftDataId = profile.id
            }
        } catch {
            print("Failed to load profile from SwiftData: \(error)")
        }
    }

    /// Restore a specific profile by id. Does not trigger a save.
    func load(byId id: UUID) async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let profile = try await profileRepository.fetchProfile(byId: id) {
                ProfileMapper.apply(profile, to: self)
                self.profileId = profile.id
                self.swiftDataId = profile.id
            }
        } catch {
            print("Failed to load profile by id from SwiftData: \(error)")
        }
    }

    /// Re-point this view model to a different stored profile: cancel any pending save, then
    /// load that entity under the `isLoading` guard (so a re-pointed field's `didSet` can't save
    /// into the old row).
    func switchProfile(to id: UUID) async {
        saveTask?.cancel()  // Don't let a pending save race the re-point
        profileId = id
        await load(byId: id)
    }

    /// Throttle saves by cancelling previous task and starting new one
    private func triggerSave() {
        guard !isLoading else { return }
        saveTask?.cancel()  // Cancel any pending save before replacing it

        saveTask = Task { [weak self] in
            // Wait for the delay
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(self.saveDelay * 1_000_000_000))

            // Check if task was cancelled during wait
            guard !Task.isCancelled else { return }

            // Perform save via repository (@MainActor, runs on main thread)
            await self.saveToSwiftData()
        }
    }

    /// Save profile data to SwiftData
    func saveToSwiftData() async {
        // Convert ProfileViewModel to Profile entity, keyed on this view model's profile id.
        let existing = try? await profileRepository.fetchProfile(byId: profileId)
        let profile = ProfileMapper.mapToEntity(self, existing: existing)
        if existing == nil { profile.id = profileId }

        // Save via repository with retry logic (background thread via actor)
        do {
            try await profileRepository.save(profile)
            self.swiftDataId = profile.id  // Store the ID after successful save
        } catch {
            // Failed after retries - could surface to user via a coordinator/delegate
            // For now, log the error
            print("Failed to save profile: \(error)")
        }
    }

    /// Copy protein/carbs/fats from a macro preset option into this profile.
    /// Call before calculating so the computation uses the user's actual selection.
    private func syncSelectedMacro() {
        // Use the environment-injected macro collection if available
        let collection = macroCollection ?? MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
        // Find the selected macro option and sync its values
        if let selected = collection.items.first(where: { $0.id == selectedMacroId }) {
            syncMacros(from: selected)
        }
    }

    /// Copy protein/carbs/fats from a macro preset option into this profile.
    func syncMacros(from macroOption: MacroSplitOptionModel) {
        protein = macroOption.protein
        carbs = macroOption.carbs
        fats = macroOption.fats
    }

    /// Creates a ShareResultsModel from the current profile and result.
    /// - Parameter result: The calculation results
    /// - Returns: A ShareResultsModel with pre-formatted data for sharing
    func createShareResultsModel(result: CalculatorResultViewModel) -> ShareResultsModel {
        // Use the environment-injected macro collection if available
        let collection = macroCollection ?? MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get())
        let selectedMacro = collection.items.first(where: { $0.id == selectedMacroId })

        return ShareResultsModel(
            profile: self,
            result: result,
            macroMethodName: selectedMacro?.name ?? "Custom",
            macroPresetName: selectedMacro?.name ?? "Custom"
        )
    }

    func updateProtein(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterProteinChange(newValue: newValue, originalCarbs: carbs, originalFats: fats)
        protein = result.protein
        carbs = result.carbs
        fats = result.fats
    }

    func updateCarbs(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterCarbsChange(newValue: newValue, originalProtein: protein, originalFats: fats)
        protein = result.protein
        carbs = result.carbs
        fats = result.fats
    }

    func updateFats(to newValue: Double) {
        let result = MacroSplitOptionModel.normalizeAfterFatsChange(newValue: newValue, originalProtein: protein, originalCarbs: carbs)
        protein = result.protein
        carbs = result.carbs
        fats = result.fats
    }

    // [Retained other methods if they do not involve calculation logic]

    nonisolated deinit {
        saveTask?.cancel()
    }
}
