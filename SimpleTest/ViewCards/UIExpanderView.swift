import SwiftUI

struct UIExpanderView<Content: View>: View {
    let isExpanded: Bool
    let content: Content

    init(isExpanded: Bool,
         @ViewBuilder content: () -> Content) {
        self.isExpanded = isExpanded
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) { // Align the VStack to leading and top
            if isExpanded {
                content
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top, 8) // add padding to the top of the view
            } 
        }
    }
}


#Preview("Toggle Control") {
    @Previewable @State var isContentExpanded = false

    VStack(alignment: .leading, spacing: 16) {
        Toggle(isOn: $isContentExpanded) {
            Text("Expand Content")
        }

        UIExpanderView(isExpanded: isContentExpanded) {
            Text(
                "This content can be expanded or collapsed based on the toggle."
                    + "\nIt demonstrates dynamic behavior in previews."
            )
            .font(.body)
            .lineLimit(3)
        }
        
        Spacer()
    }
    .padding()
}
