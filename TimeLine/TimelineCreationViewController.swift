//
//  TimelineCreationViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/12/25.
//

import UIKit

class TimelineCreationViewController: UIViewController {

    @IBOutlet weak var inviteCreatorsLabel: UILabel!
    @IBOutlet weak var timelineNameLabel: UILabel!
    
    @IBOutlet weak var timelineCreationTitleLabel: UILabel!
    
    @IBOutlet weak var createTimelineButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var timelineNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        
        // Initial Set Up
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        timelineCreationTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
    }
    
    @objc func updateFont() {
        timelineCreationTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
    }
    
    @IBAction func createTimelinePressed(_ sender: Any) {
        // To-Do: Add check for empty name field
        let name = timelineNameField.text!
        
        timelines.append(name)
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {

    }
}
