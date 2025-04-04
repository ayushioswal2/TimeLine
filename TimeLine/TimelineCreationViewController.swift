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
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var dummyCoverPhotoView: UIView!
    @IBOutlet weak var dummyPhotoIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        // Initial Set Up
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        timelineCreationTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        inviteCreatorsLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        sendButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        
        timelineCreationTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        sendButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
            
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
    
    @objc func updateFont() {
        timelineCreationTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        inviteCreatorsLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        sendButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
    }
    
    @objc func updateColorScheme() {
        timelineCreationTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        sendButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
}
