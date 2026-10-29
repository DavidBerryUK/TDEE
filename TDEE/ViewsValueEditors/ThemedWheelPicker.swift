//
//  ThemedWheelPicker.swift
//  TDEE
//

// AI AGENT WARNING: the `.wheel` style is intentional here — a wheel picker is best for ordered
// numeric values. This wraps a `UIPickerView` (a wheel, not a menu) so a theme can dress it; do not
// swap it for a dropdown. See UIWheelPickerAgeView for the same note.

import SwiftUI
import UIKit

/// A `UIPickerView`-backed wheel a theme can fully dress.
///
/// SwiftUI's `.pickerStyle(.wheel)` exposes no handle for the picker's selection band, so the
/// highlighted row stays the system's fixed grey capsule — invisible on a busy theme. This reaches the
/// underlying `UIPickerView` to (1) make its field transparent so a theme-supplied panel shows through,
/// (2) force its appearance so its digits read on a light panel, and (3) theme the selection band.
struct ThemedWheelPicker: UIViewRepresentable {
    let rows: [Int]
    @Binding var selection: Int

    /// Force the picker's appearance; `nil` inherits the app's. `.light` makes the digits dark, which
    /// is what reads on a light panel.
    var colorScheme: ColorScheme? = nil
    /// The selection band colour; `nil` keeps the system's grey indicator.
    var selectionColor: Color? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        picker.backgroundColor = .clear
        // Start on the bound value, then let the coordinator keep the binding in sync.
        if let index = rows.firstIndex(of: selection) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        applyTheme(to: picker)
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self
        applyTheme(to: picker)
        // Only re-select when the binding changed from outside the wheel: matching the picker's current
        // row avoids yanking it back while the user is mid-scroll.
        if let expected = rows.firstIndex(of: selection), picker.selectedRow(inComponent: 0) != expected {
            picker.selectRow(expected, inComponent: 0, animated: false)
        }
    }

    private func applyTheme(to picker: UIPickerView) {
        // Force the picker's appearance so its digits read on a light panel; `nil` inherits the app's.
        picker.overrideUserInterfaceStyle = {
            guard let colorScheme else { return UIUserInterfaceStyle.unspecified }
            return colorScheme == .light ? .light : .dark
        }()

        // `UIPickerView` has no public selection-indicator API, so theme the private one via KVC,
        // guarded so an OS that drops the key degrades to the system indicator instead of raising
        // `NSUnknownKeyException`.
        if let selectionColor {
            applySelectionIndicator(UIColor(selectionColor), to: picker)
        }
    }

    private func applySelectionIndicator(_ color: UIColor, to picker: UIPickerView) {
        guard picker.responds(to: NSSelectorFromString("setSelectionIndicator:")) else { return }
        picker.setValue(ThemedSelectionIndicator(color: color), forKey: "selectionIndicator")
    }

    /// Keeps a `@Binding` in sync with a `UIPickerView`: one component of integer rows.
    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: ThemedWheelPicker

        init(_ parent: ThemedWheelPicker) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.rows.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            guard row < parent.rows.count else { return nil }
            return String(parent.rows[row])
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            guard row < parent.rows.count else { return }
            parent.selection = parent.rows[row]
        }
    }
}

/// A rounded selection band for a `UIPickerView`, filled with a theme colour so the highlighted row
/// reads on-theme instead of the system's fixed grey capsule. The picker lays out its frame.
final class ThemedSelectionIndicator: UIView {
    init(color: UIColor, cornerRadius: CGFloat = 8) {
        super.init(frame: .zero)
        backgroundColor = color
        layer.cornerRadius = cornerRadius
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
