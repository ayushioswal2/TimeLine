//
//  FontManager.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/11/25.
//

import UIKit

class FontManager {
    static let shared = FontManager()
    
    private let fontKey = "selectedFont"
    
    func setFont(fontName: String) {
        UserDefaults.standard.setValue(fontName, forKey: fontKey)
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name("FontChanged"), object: nil)
    }
    
    func getFont() -> String? {
        return UserDefaults.standard.string(forKey: fontKey) ?? "Refani"
    }
}


// ** MOVE TO NEW FILE??? **
extension UIFont {
    static func appFont(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName = FontManager.shared.getFont()!
        let fontSize = UIFont.preferredFont(forTextStyle: style).pointSize  // Keep the existing size for an element
        
        if fontName == "System" {
            return UIFont.systemFont(ofSize: fontSize, weight: weight)
        }
        
        return UIFont(name: fontName, size: fontSize)!
    }
}
