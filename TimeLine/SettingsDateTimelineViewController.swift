//
//  SettingsDateTimelineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/12/25.
//

import UIKit

class SettingsDateTimelineViewController: UIViewController {

    @IBOutlet weak var settingsTitleLabel: UILabel!
    @IBOutlet weak var timelineNameLabel: UILabel!
    @IBOutlet weak var timelineNameField: UILabel!
    @IBOutlet weak var creatorsLabel: UILabel!
    @IBOutlet weak var inviteCreatorsLabel: UILabel!
    
    @IBOutlet weak var dummyCoverPhotoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        
        settingsTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .medium)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        timelineNameField.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        creatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        inviteCreatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)

        settingsTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
    
    @objc func updateFont() {
        settingsTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .medium)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        timelineNameField.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        creatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        inviteCreatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        settingsTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
    
    
}
