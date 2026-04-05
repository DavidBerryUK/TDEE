import SwiftUI

struct TestHostCatalogView: View {
    var body: some View {
        NavigationStack {
            List {
                
                // Group - Sections
                
                Section(header: Text("Sections")) {
                    NavigationLink("Gender", destination: HostSectionGender())
                    NavigationLink("Age", destination: HostSectionAge())
                    NavigationLink("Height", destination: HostSectionHeight())
                    NavigationLink("Weight", destination: HostSectionWeight())
                    NavigationLink("Activity Level", destination: HostSectionActivityLevel())
                    NavigationLink("Body Fat", destination: HostSectionBodyFatPercentage())
                }
                
                // Group - Wheel Pickers
                Section(header: Text("Wheel Pickers")) {
                    NavigationLink("Age", destination: HostWheelPickerAge())
                    NavigationLink("Activity Level", destination: HostWheelPickerActivityLevel())
                    NavigationLink("Body Fat Percentage", destination: HostWheelPickerBodyFat())
                    NavigationLink("Height", destination: HostWheelPickerHeight())
                    NavigationLink("Weight", destination: HostWheelPickerWeight())
                    
                }
                
                // Group - Segment Pickers
                Section(header: Text("Segment Pickers")) {
                    NavigationLink("Bodyfat Calculation Method", destination: HostSegmentBodyFatCalcMethod())
                    NavigationLink("Gender", destination: HostSegmentGender())
                    NavigationLink("Calorie Adjustment Method", destination: HostSegmentCalorieAdjustmentMethod())
                    NavigationLink("Length", destination: HostSegmentUomLength())
                    NavigationLink("Weight", destination: HostSegmentUomWeight())
                    NavigationLink("Macro Split Method", destination: HostSegmentMacroSplitMethod())
                }
                
                // Group - Text Values
                Section(header: Text("Text Values")) {
                    NavigationLink("Gallery", destination: HostTextValuesGallery())
                }
            }
            .listStyle(.insetGrouped) // modern grouped table style
            .navigationTitle("Host Catalog")
        }
    }
}

#Preview {
    TestHostCatalogView()
}
