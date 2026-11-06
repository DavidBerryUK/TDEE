//
//  ThemeView.swift
//  TDEE
//
//  Created by David Berry on 21/04/2026.
//
import SwiftUI

/// Lets the user pick the appearance mode and colour theme. Changes apply immediately.
struct ThemeView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.palette) private var palette

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        @Bindable var themeManager = themeManager

        // The theme cards scroll up and behind the pinned glass header below. safeAreaInset pins the
        // header and starts the cards just beneath its real height, so the first card never peeks under
        // the bar on launch — and it tracks that height, so the inset doesn't drift with Dynamic Type.
        ScrollView {
            themeSection
                .padding()
        }
        .background(palette.background.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: Spacing.large) {
            appearanceHeader
                .padding(.horizontal, Spacing.large)
                .padding(.vertical, Spacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
        }
        .navigationTitle("Theme")
    }

    /// The theme section — the only thing that scrolls.
    private var themeSection: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(DefaultThemes.all) { theme in
                ThemeCardView(theme: theme, isSelected: theme.id == themeManager.themeID) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        themeManager.themeID = theme.id
                    }
                }
            }
        }
    }

    /// The appearance mode picker, pinned to the top while the theme cards scroll behind it.
    @ViewBuilder
    private var appearanceHeader: some View {
        @Bindable var themeManager = themeManager

        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Appearance")
            Picker("Appearance", selection: $themeManager.appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            // A theme that pins its colour scheme ignores the Appearance choice.
            .disabled(themeManager.theme.colorScheme != nil)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(palette.textSecondary)
    }
}

#Preview {
    let manager = ThemeManager(defaults: UserDefaults(suiteName: "ThemeViewPreview")!)
    NavigationStack {
        ThemedRoot(themeManager: manager) {
            ThemeView()
        }
    }
}
