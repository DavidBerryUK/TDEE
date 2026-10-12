import SwiftUI

struct MainSectionMacroMix: View {

    let macroMix: MacroSplitViewModel
    let sectionManager: SectionManagerViewModel
    let calculationResult: CalculatorResultViewModel
    @Binding var path: [EnumAppRoute]
    let outerScrollViewProxy: ScrollViewProxy

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            SectionMacroSplit(macroMix: macroMix, sectionManager: sectionManager, calculationResult: calculationResult, path: $path, proxy: outerScrollViewProxy)
                .id("MacroSplit")
            Divider()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .clipped()
        .onChange(of: sectionManager.macroMixExpanded) { _, newValue in
            if newValue {
                scrollIfNecessary()
            }
        }
    }

    private func scrollIfNecessary() {
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // Delay of 0.2 seconds (200 ms)
            withAnimation(.easeInOut(duration: 0.3)) {
                outerScrollViewProxy.scrollTo("MacroSplit", anchor: .top)
            }
        }
    }
}
