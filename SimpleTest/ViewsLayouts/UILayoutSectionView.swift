//
//  UILayoutSectionView.swift
//  SimpleTest
//
//  Created by David Berry on 05/04/2026.
//
import SwiftUI

struct UILayoutSectionView<SectionSummaryValueView: View, EditorView: View>: View {

    let title: String
    let icon : EnumIcon // Assuming this type exists
    @Binding var isExpanded: Bool
    let validationText : String
    let accessibilityId: String?

    let sectionSummaryValueView: () -> SectionSummaryValueView
    let editorView: () -> EditorView

    // Update hasError to control the isVisible binding
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium)
        {

            // First row: header only (icon, title, summary, chevron) with internal 16pt padding and error highlight
            HStack {
                UIIcon(icon: icon, style: .coloredBackgroundSolid)
                Text(title)
                    .font(.headline)
                    .contentTransition(.interpolate)
                    // Animation is harder to fully refactor without knowing the full build setup, keeping explicit type for now.
                    .animation(.easeInOut, value: title)
                Spacer()
                sectionSummaryValueView()
                Image(systemName: "chevron.down")
                    // FIX 2: Using constant animation
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(AnimationParams.springDefault, value: isExpanded)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(Spacing.large) // <-- FIX 3: Using constant for main header padding (replaces 16)
            .contentShape(Rectangle()) // Make the entire HStack area tappable
            .onTapGesture {
                withAnimation(AnimationParams.springDefault) { // <-- FIX 4: Using animation constant
                    isExpanded.toggle()
                }
            }

            // Add the UILabelValidationMessage with animation - only shown when there's validation text
            if !validationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                UILabelValidationMessage(validationText)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    // FIX 5: Using animation constant
                    .animation(AnimationParams.fastDuration, value: validationText)
            }

            // Expanded content: outside of the error background
            if isExpanded {
                editorView()
                    .padding(.top, Spacing.medium) // <-- FIX 6: Using constant for top padding (replaces 12)
                    .padding(.bottom, Spacing.small) // <-- FIX 7: Using constant for bottom padding (replaces 8)
            }
        }
        // Make the entire VStack area tappable
        .contentShape(Rectangle())
        // Expose the section as a container whose children remain individually queryable.
        // NOTE: a bare `.accessibilityElement()` means `children: .ignore`, which hides every
        // descendant. It used to be applied here immediately before the `.contain` variant; the
        // two contradict each other. Do not reintroduce it.
        .accessibilityElement(children: .contain)
        // animation to assist in the Validation message appearing / disappearing smoothly
        .animation(AnimationParams.fastDuration, value: validationText) // <-- FIX 8: Using animation constant
        .accessibilityIdentifier(accessibilityId ?? "")
    }
}

#Preview("Normal") {
    @Previewable @State var model = ProfileViewModel()
    @Previewable @State var sectionManager = SectionManagerViewModel()

    UILayoutSectionView(
        title: "Weight",
        icon: .weight,
        isExpanded: $sectionManager.weightIsExpanded,
        validationText: "",
        accessibilityId: nil,
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
    @Previewable @State var sectionManager = SectionManagerViewModel()
    let validationText = "Weight is required"

    UILayoutSectionView(
        title: "Weight",
        icon: .weight,
        isExpanded: $sectionManager.weightIsExpanded,
        validationText: validationText,
        accessibilityId: nil,
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
    @Previewable @State var sectionManager = SectionManagerViewModel()
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
            accessibilityId: nil,
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
