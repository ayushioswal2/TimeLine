//
//  SettingsDateTimelineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/12/25.
//

import UIKit

class SettingsDateTimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var settingsTitleLabel: UILabel!
    @IBOutlet weak var timelineNameLabel: UILabel!
    @IBOutlet weak var timelineNameField: UILabel!
    @IBOutlet weak var creatorsLabel: UILabel!
    @IBOutlet weak var inviteCreatorsLabel: UILabel!
    
    @IBOutlet weak var emailForInviteField: UITextField!
    
    @IBOutlet weak var creatorListTable: UITableView!
    var creatorList: [String] = ["Tester1", "Tester2"]
    
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
        
        creatorListTable.dataSource = self
        creatorListTable.delegate = self
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creatorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatorCell", for: indexPath) as! CreatorListViewCell
        cell.creatorNameLabel.text = creatorList[indexPath.row]

        return cell
    }
    
    @IBAction func sendInviteButtonPressed(_ sender: Any) {
        if emailForInviteField.text != "" {
            creatorList.append(emailForInviteField.text!)
        }
        emailForInviteField.text = ""
        creatorListTable.reloadData()
    }
    
    
    
}
