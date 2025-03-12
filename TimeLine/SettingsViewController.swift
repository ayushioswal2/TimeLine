//
//  SettingsViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/10/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var colorSegControl: UISegmentedControl!

    let button = UIButton(primaryAction: nil)
    let fontList = ["Refani", "System"]
    
    let settingTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        
        settingTitle.text = "User Settings"
        settingTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        settingTitle.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        settingTitle.frame = CGRect(x: 100, y: 100, width: 300, height: 100)
        self.view.addSubview(settingTitle)
    }
    
    func fontButton() {
        let actionClosure = { (action: UIAction) in
            print(action.title)
            let selectedFont = action.title.isEmpty ? "Refani" : action.title

            FontManager.shared.setFont(fontName: selectedFont)
        }

        var menuChildren: [UIMenuElement] = []
        for font in fontList {
            menuChildren.append(
                UIAction(title: font, handler: actionClosure))
        }

        button.menu = UIMenu(options: .displayInline, children: menuChildren)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true

        button.frame = CGRect(x: 200, y: 250, width: 100, height: 40)
        self.view.addSubview(button)
    }
    
    @objc func updateFont() {
            self.settingTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }

//    @IBAction func colorSelectionSegControl(_ sender: Any) {
//        switch colorSegControl.selectedSegmentIndex {
//            case 0:
//            print("Red")
//        case 1:
//            print("Blue")
//        case 2:
//            print("Green")
//        default:
//            print("Default")
//        }
//    }
}
