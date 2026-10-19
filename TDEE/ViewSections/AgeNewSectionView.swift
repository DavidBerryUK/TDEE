//
//  AgeNewSectionView.swift
//  TDEE
//
//  Created by David Berry on 19/10/2026.
//

import SwiftUI
import Observation

/// The New age input section (story 023, input #2).
///
/// A layout redesign of the age control, like `GenderNewSectionView`: there is no expand/collapse
/// panel — the control lives inline in the section header. Unlike gender, though, this control is
/// genuinely new: a numeric text field (the app's first text entry) that can surface a validation
/// message.
///
/// The field keeps a local text buffer and commits to `model.age` only when the entry parses *and*
/// falls inside `MetricRanges.age`; an out-of-range or empty entry shows a `UILabelValidationMessage`
/// and leaves the model's last valid value untouched.
///
/// `MainSectionProfileInput` selects this via `InputStyleManager` when age's style is `.new`.
struct AgeNewSectionView: View {

    @Bindable var model: ProfileViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// What the field shows. A local buffer so an out-of-range entry never reaches `model.age`.
    @State private var text: String = ""
    /// The current validation message — "" when valid.
    @State private var error: String = ""

    var body: some View {
        // At accessibility sizes the control gets its own full-width line so neither the title
        // nor the field is squeezed; otherwise it trails the header row.
        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? Spacing.small : 0) {
            HStack {
                UIIcon(icon: .age, style: .coloredBackgroundSolid)
                Text("Age")
                    .font(.headline)
                // Guaranteed breathing room between the label and the field.
                Spacer(minLength: Spacing.large)
                if !dynamicTypeSize.isAccessibilitySize {
                    field
                }
            }
            if dynamicTypeSize.isAccessibilitySize {
                field
            }
            // The error (if any) spans the full width under the header.
            UILabelValidationMessage(error)
        }
        .padding(Spacing.large)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .onAppear { text = String(model.age) }
        // Keep the field in step with the model when it changes elsewhere (profile switch, reset).
        .onChange(of: model.age) { _, newValue in
            text = String(newValue)
            error = ""
        }
    }

    /// The age entry: a bordered, prompt-bearing numeric field so it reads as an editable input
    /// rather than a static number. Compact and trailing in the header; full-width on its own line at
    /// accessibility sizes.
    @ViewBuilder
    private var field: some View {
        TextField("Age", text: $text, prompt: Text("Enter age"))
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 96)
            .onChange(of: text) { _, newValue in
                validate(newValue)
            }
    }

    /// Parse the buffer and commit only when it is a valid, in-range age.
    private func validate(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let value = Int(trimmed), MetricRanges.age.contains(value) {
            // Commit only on a real change, so re-typing the same value doesn't re-trigger a save.
            if model.age != value { model.age = value }
            error = ""
        } else if trimmed.isEmpty {
            error = "Age is required"
        } else {
            let range = MetricRanges.age
            error = "Age must be \(range.lowerBound)…\(range.upperBound)"
        }
    }
}

#Preview {
    AgeNewSectionView(model: ProfileViewModel())
}
