//
//  UIApplication+Keyboard.swift
//  TDEE
//
//  Created by David Berry on 27/10/2026.
//

import UIKit

extension UIApplication {
    /// Dismiss the keyboard by resigning whichever view is the first responder — the same call a
    /// keyboard "Done" key makes. Used by the screen-level "Done" button and by tap-outside-to-end
    /// the edit (tap on a panel/background), so a single, uniform mechanism covers every entry.
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil)
    }
}
