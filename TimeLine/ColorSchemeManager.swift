//
//  ColorSchemeManager.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/27/25.
//

import UIKit

class ColorSchemeManager {
    static let shared = ColorSchemeManager()
    
    private let colorSchemeKey = "selectColorScheme"
    
    func setColorScheme(colorChoice: String) {
        UserDefaults.standard.set(colorChoice, forKey: colorSchemeKey)
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name("ColorSchemeChanged"), object: nil)
    }
    
    func getColorScheme() -> String? {
        return UserDefaults.standard.string(forKey: colorSchemeKey) ?? "Red"
    }
}

extension UIColor {
    static func appColorScheme(type: String) -> UIColor {
        let colorScheme = ColorSchemeManager.shared.getColorScheme()!
        
        if colorScheme == "red" {
            if type == "secondary" {
                return UIColor(red: 125/255, green: 66/255, blue: 62/255, alpha: 1)
            }
            return UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        } else if colorScheme == "green" {
            if type == "secondary" {
                return UIColor(red: 83/255, green: 119/255, blue: 62/255, alpha: 1)
            }
            return UIColor(red: 45/255, green: 75/255, blue: 51/255, alpha: 1)
        } // else selected color scheme is blue
        if type == "secondary" {
            return UIColor(red: 46/255, green: 83/247, blue: 119/255, alpha: 1)
        }
        return UIColor(red: 14/255, green: 25/255, blue: 83/255, alpha: 1)
    }
}

