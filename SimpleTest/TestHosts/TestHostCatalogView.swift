import SwiftUI

struct TestHostCatalogView: View {
    var body: some View {
        NavigationStack {
            List {
                // Group #1 - Wheel Pickers
                Section(header: Text("Wheel Pickers")) {
                    NavigationLink("Age", destination: HostWheelPickerAge())
                    NavigationLink("Height", destination: HostWheelPickerHeight())
                    NavigationLink("Weight", destination: HostWheelPickerWeight())                    
                }
                
                // Group #2 - Segment Pickers
                Section(header: Text("Segment Pickers")) {
                    NavigationLink("Activity Level", destination: HostWheelPickerActivityLevel())
                    NavigationLink("Bodyfat Calculation Method", destination: HostSegmentBodyFatCalcMethod())
                    NavigationLink("Gender", destination: HostSegmentGender())
                    NavigationLink("Length", destination: HostSegmentUomLength())
                    NavigationLink("Weight", destination: HostSegmentUomWeight())
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
