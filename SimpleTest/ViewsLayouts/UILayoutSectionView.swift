//
//  UILayoutSectionView.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//

import SwiftUI

struct UILayoutSectionView<SectionSummaryValueView: View, EditorView: View>: View {
    
    let title: String
    let icon : EnumIcon
    @Binding var isExpanded: Bool
    let validationText : String
    
    let sectionSummaryValueView: () -> SectionSummaryValueView
    let editorView: () -> EditorView

    // Update hasError to control the isVisible binding
    var body: some View {

        VStack(alignment: .leading, spacing: 0) {
            
            // First row: header only (icon, title, summary, chevron) with internal 16pt padding and error highlight
            HStack {
                UIIcon(icon: icon, style: .coloredBackgroundSolid)
                Text(title)
                    .font(.headline)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut, value: title)
                Spacer()
                sectionSummaryValueView()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .contentShape(Rectangle()) // Make the entire HStack area tappable
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }

            // Add the UILabelValidationMessage with animation - only shown when there's validation text
            if !validationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                UILabelValidationMessage(validationText)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: validationText)
            }

            // Expanded content: outside of the error background
            if isExpanded {
                editorView()
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }
        }
        // animation to assist in the Validation message appearing / disappearing smoothly
        .animation(.easeInOut(duration: 0.3), value: validationText)
    }
}

#Preview("Normal") {
    @Previewable @State var model = ProfileViewModel()
    @Previewable @StateObject var sectionManager = SectionManagerViewModel()
    
    UILayoutSectionView(
        title: "Weight",
        icon: .weight,
        isExpanded: $sectionManager.weightIsExpanded,
        validationText: "",
        sectionSummaryValueView: {
            Text("75 kg")
        },
        editorView: {
            HStack {
                Text("Content goes here")
                Spacer()
            }
        }
    )
}

#Preview("With Error") {
    @Previewable @State var model = ProfileViewModel()
    @Previewable @StateObject var sectionManager = SectionManagerViewModel()
    let validationText = "Weight is required"
    
    UILayoutSectionView(
        title: "Weight",
        icon: .weight,
        isExpanded: $sectionManager.weightIsExpanded,
        validationText: validationText,
        sectionSummaryValueView: {
            Text("75 kg")
        },
        editorView: {
            HStack {
                Text("Content goes here")
                Spacer()
            }
        }
    )
}

#Preview("Interactive Error Toggle") {
    @Previewable @StateObject var sectionManager = SectionManagerViewModel()
    @Previewable @State var showError: Bool = false
    @Previewable @State var expanded: Bool = false

    VStack(alignment: .leading, spacing: 16) {
        Toggle("Show Error", isOn: $showError)
        Toggle("Expanded", isOn: $expanded)

        UILayoutSectionView(
            title: "Weight",
            icon: .weight,
            isExpanded: $expanded,
            validationText: showError ? "Weight is required" : "",
            sectionSummaryValueView: {
                Text("75 kg")
            },
            editorView: {
                HStack {
                    Text("Content goes here")
                    Spacer()
                }
            }
        )
    }
    .padding()
}
