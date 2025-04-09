//
//  SettingsViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/10/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsTitleLabel: UILabel!
    @IBOutlet weak var navBarToggleLabel: UILabel!
    @IBOutlet weak var selectFontLabel: UILabel!
    @IBOutlet weak var selectColorThemeLabel: UILabel!

    @IBOutlet weak var colorSchemeSegControl: UISegmentedControl!
    
    let fontChangeButton = UIButton(primaryAction: nil)
    let fontList = ["Refani", "System"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontButton()
        
        // waits for notification that font has been changed
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        settingsTitleLabel.text = "User Settings"
        settingsTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        settingsTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        
        colorSegControlSetup()
    }
    
    func fontButton() {
        // creates dropdown menu with font choices
        let actionClosure = { (action: UIAction) in
            FontManager.shared.setFont(fontName: action.title)
        }

        var menuChildren: [UIMenuElement] = []
        for font in fontList {
            let action = UIAction(title: font, handler: actionClosure)
            
            // If the font matches the current font, mark it as selected
            if let currentFont = FontManager.shared.getFont() {
                if (font == currentFont) {
                    action.state = .on // Mark this action as selected
                }
            }
            menuChildren.append(action)
        }
        
        fontChangeButton.menu = UIMenu(options: .displayInline, children: menuChildren)
        fontChangeButton.showsMenuAsPrimaryAction = true
        fontChangeButton.changesSelectionAsPrimaryAction = true

        // set title of button to current font
        if let currentFont = FontManager.shared.getFont() {
           self.fontChangeButton.setTitle(currentFont, for: .normal)
        }
        
        fontChangeButton.frame = CGRect(x: 290, y: 320, width: 100, height: 40)
        self.view.addSubview(fontChangeButton)
    }
    
    @objc func updateFont() {
        settingsTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        
        navBarToggleLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        selectFontLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        selectColorThemeLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    func colorSegControlSetup() {
        // resize segControl to be bigger
        colorSchemeSegControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSchemeSegControl.heightAnchor.constraint(equalToConstant: 200) // Set desired height
        ])
        
        // Set selected item in seg control to current color choice
        if ColorSchemeManager.shared.getColorScheme()! == "red" {
            colorSchemeSegControl.selectedSegmentIndex = 0
        } else if ColorSchemeManager.shared.getColorScheme()! == "green" {
            colorSchemeSegControl.selectedSegmentIndex = 1
        } else {
            colorSchemeSegControl.selectedSegmentIndex = 2
        }
    }
    
    @IBAction func colorSchemeSegControlChanged(_ sender: Any) {
        switch colorSchemeSegControl.selectedSegmentIndex {
        case 0:
            ColorSchemeManager.shared.setColorScheme(colorChoice: "red")
        case 1:
            ColorSchemeManager.shared.setColorScheme(colorChoice: "green")
        case 2:
            ColorSchemeManager.shared.setColorScheme(colorChoice: "blue")
        default:
            break
        }
    }
    
    @objc func updateColorScheme() {
        settingsTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
    }
}
