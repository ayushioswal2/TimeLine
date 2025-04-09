//
//  ScrapbookViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit

class ScrapbookViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)

        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")

        saveButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        saveButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @objc func updateFont() {
        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        saveButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")
        saveButton.backgroundColor = UIColor.appColorScheme(type: "secondary")

    }
}
