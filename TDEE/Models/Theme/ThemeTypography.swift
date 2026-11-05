//
//  ThemeTypography.swift
//  TDEE
//

import SwiftUI
import UIKit
import CoreText

/// The typeface a theme sets for its text — the model-layer analogue of `PickerDressing`,
/// `SectionDressing` and `GlowDressing`. A theme that doesn't opt in leaves `Theme.typeface == nil`, so
/// `PaletteResolver` injects `.system` and every existing theme renders byte-for-byte unchanged — the
/// opt-in discipline the other dressings use.
///
/// Each text role resolves to the SAME size and weight the system style gives, in the theme's registered
/// family — so a call site swaps `.font(.headline)` for `.font(typography.headline)` and only the family
/// changes. The size comes from `UIFont.preferredFont(forTextStyle:)` at render time, so the custom family
/// still scales with Dynamic Type (a clinical theme must not regress accessibility); the weight is a
/// `UIFontDescriptor` weight attribute, so one bundled variable font serves every weight.
struct ThemeTypography: Equatable {
    /// The registered font family (e.g. "Source Sans 3"); `nil` means the system font.
    let familyName: String?

    /// The system typeface: no family, so every role returns the exact system text style (unchanged).
    static let system = ThemeTypography(familyName: nil)

    init(familyName: String?) {
        self.familyName = familyName
    }

    /// Whether this typeface sets a custom family (vs the system).
    var isCustom: Bool { familyName != nil }

    /// The clinical sans bundled with the Medical theme.
    static let sourceSans3 = ThemeTypography(familyName: "Source Sans 3")

    // MARK: Resolution

    /// A Dynamic-Type role's `Font`: the exact system style when there's no custom family (so non-custom
    /// themes are byte-for-byte unchanged), else the custom family at the role's Dynamic-Type-scaled size
    /// and weight.
    ///
    /// `UIFont.preferredFont(forTextStyle:)` reads the current content-size category, so the custom family
    /// scales with Dynamic Type exactly like the system style it replaces. If the family isn't registered
    /// (e.g. the bundle failed) the role degrades to the exact system style, never a blank.
    func resolve(_ system: Font, _ uiStyle: UIFont.TextStyle, weight: Font.Weight = .regular) -> Font {
        guard let family = familyName else { return system }
        let size = UIFont.preferredFont(forTextStyle: uiStyle).pointSize
        if let uiFont = customFont(family: family, size: size, weight: weight) {
            return Font(uiFont)
        }
        return system
    }

    /// A fixed-size role for surfaces where Dynamic Type is moot (the share card renders at a fixed
    /// 1080×1350). The system path keeps the exact `.system(size:weight:design:)`; the custom path uses the
    /// family at the given size/weight (a clinical face has no rounded variant, so `design` is dropped on
    /// the custom path only) and falls back to the system font if the family isn't registered.
    func fixed(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        guard let family = familyName else { return .system(size: size, weight: weight, design: design) }
        if let uiFont = customFont(family: family, size: size, weight: weight) {
            return Font(uiFont)
        }
        return .system(size: size, weight: weight, design: design)
    }

    /// A `UIFont` in `family` at `size`/`weight`, or `nil` if the family isn't registered. A variable font
    /// selects its weight from the descriptor's weight attribute; a static family simply returns its
    /// regular instance (a non-matching weight degrades to regular rather than failing).
    private func customFont(family: String, size: CGFloat, weight: Font.Weight) -> UIFont? {
        var attributes: [UIFontDescriptor.AttributeName: Any] = [.family: family]
        attributes[UIFontDescriptor.AttributeName(rawValue: "UIFontWeightAttribute")] = weight.uiWeightValue
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: size)
    }

    // MARK: Text roles, mirroring the system styles this app uses.

    var largeTitle: Font { resolve(.largeTitle, .largeTitle) }
    var headline: Font { resolve(.headline, .headline, weight: .semibold) }
    var subheadline: Font { resolve(.subheadline, .subheadline) }
    var callout: Font { resolve(.callout, .callout) }
    var body: Font { resolve(.body, .body) }
    var footnote: Font { resolve(.footnote, .footnote) }
    var caption: Font { resolve(.caption, .caption1) }

    // MARK: Bundled-font registration

    /// Registers the bundled font files in `bundle` so a custom family resolves. Idempotent and safe to
    /// call once at launch; a missing file is a no-op, so a theme whose font didn't bundle simply degrades
    /// to the system face.
    static func registerBundledFonts(in bundle: Bundle = .main) {
        // One file per family; the filename is decoupled from the internal family name used above.
        let files = ["SourceSans3"]
        for file in files {
            if let url = bundle.url(forResource: file, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}

extension Font.Weight {
    /// The Core Text / `UIFont.Weight` numeric value. The two scales match exactly; `Font.Weight` isn't
    /// `RawRepresentable`, so this is the bridge to the `UIFontDescriptor` weight attribute.
    var uiWeightValue: Double {
        switch self {
        case .ultraLight: return -0.8
        case .thin:       return -0.6
        case .light:      return -0.4
        case .regular:    return 0.0
        case .medium:     return 0.21875
        case .semibold:   return 0.375
        case .bold:       return 0.578125
        case .heavy:      return 0.765625
        case .black:      return 0.8
        // `Font.Weight` is a non-frozen (non-exhaustive) enum — Apple can add cases — so a plain
        // `default` is the correct, warning-free form. Unhandled weights degrade to regular (0.0):
        // the variable font still renders, just at its regular weight.
        default:
            return 0.0
        }
    }
}
