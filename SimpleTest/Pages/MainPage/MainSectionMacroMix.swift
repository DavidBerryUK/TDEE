import SwiftUI

struct MainSectionMacroMix: View {

    let macroMix: MacroSplitOptionsViewModel
    let sectionManager: SectionManagerViewModel
    let calculationResult: CalculatorResultViewModel
    let selectedMacro: MacroSplitOptionsModel?

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            SectionMacroSplit(macroMix: macroMix, sectionManager: sectionManager)
            Divider()
            SectionMacroMixResults(calculationResults: calculationResult)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .clipped()
    }
}

#Preview {
    MainSectionMacroMix(
        macroMix: MacroSplitOptionsViewModel(),
        sectionManager: SectionManagerViewModel(),
        calculationResult: CalculatorResultViewModel(), // Ensure this is correct
        selectedMacro: nil
    )
}

