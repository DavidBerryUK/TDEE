//
//  UILayoutSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//
import SwiftUI

/// A reusable section view with expand/collapse functionality.
///
/// This view provides a consistent UI pattern for sections in the app,
/// including a header with icon, title, summary, chevron, and content area.
/// The section can be expanded or collapsed to show/hide the editor view.
struct UILayoutSectionView<SectionSummaryValueView: View, EditorView: View>: View {
    @Environment(\.palette) private var palette

    /// The section title displayed in the header
    let title: String
    /// The icon to display in the header
    let icon : Icon // Assuming this type exists
    @Binding var isExpanded: Bool
    /// Validation error text to display (if any)
    let validationText : String
    /// Accessibility identifier for this section
    let accessibilityId: String?
    /// Unique identifier for auto-scroll targeting
    let sectionId: String?

    /// A view builder that returns the summary value view
    let sectionSummaryValueView: () -> SectionSummaryValueView
    /// A view builder that returns the editor view shown when expanded
    let editorView: () -> EditorView
    /// A ScrollViewProxy for auto-scrolling when section expands
    let proxy: ScrollViewProxy?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var titleText: some View {
        Text(title)
            .font(.headline)
            .contentTransition(.interpolate)
            .animation(.easeInOut, value: title)
    }

    private var chevron: some View {
        Image(systemName: "chevron.down")
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .animation(AnimationParams.springDefault, value: isExpanded)
            .font(.subheadline)
            .foregroundStyle(palette.textSecondary)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium)
        {

            // First row: header only (icon, title, summary, chevron) with internal 16pt padding and error highlight
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    // Accessibility sizes: the value gets its own full-width line under the title,
                    // so neither the title nor the value is squeezed into breaking mid-word.
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        HStack {
                            UIIcon(icon: icon, style: .coloredBackgroundSolid)
                            titleText
                            Spacer()
                            chevron
                        }
                        sectionSummaryValueView()
                    }
                } else {
                    HStack {
                        UIIcon(icon: icon, style: .coloredBackgroundSolid)
                        titleText
                        Spacer()
                        sectionSummaryValueView()
                        chevron
                    }
                }
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
        .accessibilityElement(children: .contain)
        .animation(AnimationParams.fastDuration, value: validationText)
        .accessibilityIdentifier(accessibilityId ?? "")
        // Auto-scroll when section expands
        .onChange(of: isExpanded) { _, expanded in
            if expanded, let sectionId = sectionId, let proxy = proxy {
                Task {
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s delay
                    proxy.scrollTo(sectionId, anchor: .top)
                }
            }
        }
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
        sectionId: "sectionWeight",
        sectionSummaryValueView: {
            Text("75 kg")
        },
        editorView: {
            HStack {
                Text("Content goes here")
                Spacer()
            }
        },
        proxy: nil
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
        sectionId: "sectionWeight",
        sectionSummaryValueView: {
            Text("75 kg")
        },
        editorView: {
            HStack {
                Text("Content goes here")
                Spacer()
            }
        },
        proxy: nil
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
            sectionId: "sectionWeight",
            sectionSummaryValueView: {
                Text("75 kg")
            },
            editorView: {
                HStack {
                    Text("Content goes here")
                    Spacer()
                }
            },
            proxy: nil
        )
    }
    .padding()
}
