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

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Appearance")
                    Picker("Appearance", selection: $themeManager.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Theme")
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
            }
            .padding()
        }
        .background(palette.background.ignoresSafeArea())
        .navigationTitle("Theme")
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
