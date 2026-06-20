//
//  UIValidationCard.swift
//  SimpleTest
//
//  Created by David Berry on 06/06/2026.
//

//
//  UITextPickerLabel.swift
//  SimpleTest
//
//  Created by David Berry on 03/04/2026.
//
import SwiftUI

struct UILabelValidationMessage: View {
    let text: String

    init(_ text: String = "") {
        self.text = text
    }

    var body: some View {
        // Keep the view in layout and animate visibility to avoid jerky insert/removal
        let isVisible = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(.red.opacity(0.9))

                Text(text)
                    .font(.body)
                    .foregroundStyle(.red.opacity(0.9))
                    .fontWeight(.regular)
            }
            .padding(.leading, 16).padding(.bottom, 8)
            .opacity(isVisible ? 1 : 0)
            .frame(height: isVisible ? nil : 0, alignment: .top)
            .clipped()
        }
        .animation(.easeInOut(duration: 0.25), value: isVisible)
    }
}

#Preview("Blank") {
    UILabelValidationMessage("")
}

#Preview("Height") {
    UILabelValidationMessage("Height is required")
}

#Preview("Weight") {
    UILabelValidationMessage("Weight is required")
}

#Preview("Interactive") {
    struct InteractivePreview: View {
        @State private var message: String = "Weight is required"

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Enter validation message", text: $message)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                UILabelValidationMessage(message)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
    }
    return InteractivePreview()
}
