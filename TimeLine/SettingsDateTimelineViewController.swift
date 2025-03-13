//
//  SettingsDateTimelineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/12/25.
//

import UIKit

class SettingsDateTimelineViewController: UIViewController {

    @IBOutlet weak var settingsTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        settingsTitleLabel.font = UIFont(name: "Refani", size: CGFloat(30))
    }
}
