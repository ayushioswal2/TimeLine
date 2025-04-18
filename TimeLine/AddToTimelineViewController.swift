//
//  AddToTimelineViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 4/18/25.
//

import UIKit

class AddToTimelineViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectDateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        updateFont()
        updateColorScheme()
    }
    
    @objc func updateFont() {
        titleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        selectDateLabel.font = UIFont.appFont(forTextStyle: .body)
        doneButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body)
    }
    
    @objc func updateColorScheme() {
        titleLabel.textColor = UIColor.appColorScheme(type: "primary")
        doneButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {        
        dates.append(datePicker.date)
        dates.sort()
    }
}
