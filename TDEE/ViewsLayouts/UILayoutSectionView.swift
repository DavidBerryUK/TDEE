//
//  UILayoutSectionView.swift
//  TDEE
//
//  Created by David Berry on 05/04/2026.
//
import SwiftUI
import UIKit

/// A reusable section view with expand/collapse functionality.
///
/// This view provides a consistent UI pattern for sections in the app,
/// including a header with icon, title, summary, chevron, and content area.
/// The section can be expanded or collapsed to show/hide the editor view.
struct UILayoutSectionView<SectionSummaryValueView: View, EditorView: View>: View {
    @Environment(\.palette) private var palette
    @Environment(\.themeTypography) private var typography

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
    /// Optional content shown whether or not the section is expanded, so a section can always surface
    /// its summary output (e.g. result cards). `nil` — the default — keeps the classic behavior where
    /// the whole section body collapses away. The macro card uses this to keep its protein/carbs/fats
    /// results visible even when collapsed, the way the calories card always shows its result.
    let persistentContent: (() -> any View)?
    /// A ScrollViewProxy for auto-scrolling when section expands
    let proxy: ScrollViewProxy?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // An explicit initializer so `persistentContent` can carry a default (`nil`) at the call site.
    // A `let` property whose type is an optional `any View`-returning closure is *excluded* from the
    // synthesized memberwise initializer, so the default has to live on the parameter instead.
    init(
        title: String,
        icon: Icon,
        isExpanded: Binding<Bool>,
        validationText: String,
        accessibilityId: String?,
        sectionId: String?,
        sectionSummaryValueView: @escaping () -> SectionSummaryValueView,
        editorView: @escaping () -> EditorView,
        persistentContent: (() -> any View)? = nil,
        proxy: ScrollViewProxy?
    ) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.validationText = validationText
        self.accessibilityId = accessibilityId
        self.sectionId = sectionId
        self.sectionSummaryValueView = sectionSummaryValueView
        self.editorView = editorView
        self.persistentContent = persistentContent
        self.proxy = proxy
    }

    private var titleText: some View {
        Text(title)
            .font(typography.headline)
            .contentTransition(.interpolate)
            .animation(.easeInOut, value: title)
            // A neon heading bloom in the section's own hue — the dressed input sections glow their rainbow
            // hue, the non-dressed result/macro sections glow the house neon. `nil` for every theme that
            // doesn't opt in → unchanged.
            .neonHeading(palette.glow, color: palette.sectionAccent)
    }

    private var chevron: some View {
        Image(systemName: "chevron.down")
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .animation(AnimationParams.springDefault, value: isExpanded)
            .font(typography.subheadline)
            .foregroundStyle(palette.textSecondary)
    }

    /// The editor region shown when the section is open. When the theme supplies an
    /// `expandedContentBackground`, the editor sits on that tint — a rounded panel (12 pt, matching the
    /// enclosing card) below the header — so the open content stands away from the section's `surface`.
    /// With no override the content is unchanged and stays on `surface`, exactly as before.
    @ViewBuilder
    private var expandedContent: some View {
        let content = editorView()
            .padding(.top, Spacing.medium) // <-- FIX 6: Using constant for top padding (replaces 12)
            .padding(.bottom, Spacing.small) // <-- FIX 7: Using constant for bottom padding (replaces 8)
        if let background = palette.expandedContentBackground {
            content
                .frame(maxWidth: .infinity)
                // Rounded like the enclosing input card and the wheel panels it wraps (both 12 pt),
                // so the tint reads as a nested panel rather than a hard-edged block. Only the fill is
                // rounded: the capsule tab and the already-rounded wheels sit inset, so nothing pokes out.
                .background(background, in: RoundedRectangle(cornerRadius: 12))
                // 4 pt off each edge: the panel stops butting against the card's left/right sides.
                .padding(.horizontal, 4)
                // 4 pt below the panel too: a small gap so the tint doesn't butt against the card's
                // bottom edge, mirroring the left/right insets.
                .padding(.bottom, 4)
        } else {
            content
        }
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
                // End any in-progress edit on a section-header tap — this header is the reusable one
                // every section (incl. Macro Split) uses, and it consumes the tap, so a tap that
                // would otherwise fall through to the screen-level handler is handled here instead.
                UIApplication.shared.endEditing()
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

            // Persistent content: shown whether or not the section is expanded, so a section can always
            // surface its summary output (e.g. the macro card's protein/carbs/fats result cards).
            // `AnyView` erases the `any View` return so the builder accepts it.
            if let persistentContent = persistentContent {
                AnyView(persistentContent())
            }

            // Expanded content: outside of the error background
            if isExpanded {
                expandedContent
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
