import SwiftUI

struct MainSectionMacroMix: View {
    
    let macroMix: MacroSplitViewModel
    let sectionManager: SectionManagerViewModel
    let macroMixResults: MacroSplitResultViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            SectionMacroMix(macroMix: macroMix, sectionManager: sectionManager)
            Divider()
            SectionMacroMixResults(macroMixResults: macroMixResults)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .clipped()
    }
}

#Preview {
    MainSectionMacroMix(
        macroMix: MacroSplitViewModel(),
        sectionManager: SectionManagerViewModel(),
        macroMixResults: MacroSplitResultViewModel()
    )
}
