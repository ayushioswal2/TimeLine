//
//  DateTimlineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/11/25.
//

import UIKit

var deletionOccurred: Bool = false

class TimelineMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var datesTableView: UITableView!
    @IBOutlet weak var timelineTitleLabel: UILabel!
    @IBOutlet weak var addToTimelineButton: UIButton!
    @IBOutlet weak var timelineSettingsButton: UIButton!
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        timelineTitleLabel.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)

        timelineTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        timelineTitleLabel.text = currTimeline?.name
        
        datesTableView.dataSource = self
        datesTableView.delegate = self
        self.datesTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        addToTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        timelineSettingsButton.tintColor = UIColor.appColorScheme(type: "secondary")

        formatter.dateFormat = "MMMM d, yyyy"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFont()
        updateColorScheme()
        
        timelineTitleLabel.text = currTimeline?.name

        datesTableView.reloadData()
        
        if deletionOccurred {
            self.navigationController?.popViewController(animated: true)
            deletionOccurred = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
        
        let formattedDate = formatter.string(from: dates[indexPath.row])
        print(formattedDate)
        cell.dateLabel.text = formattedDate
        return cell
    }
    
    @objc func updateFont() {
        timelineTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        // Load the other storyboard
        let storyboard = UIStoryboard(name: "IndividualTimeline", bundle: nil)

        // Instantiate the DateTimelineViewController directly
        if let dateTimelineVC = storyboard.instantiateViewController(withIdentifier: "SettingsDateTimelineId") as? TimelineSettingsViewController {

            // Push onto the current navigation stack
            self.navigationController?.pushViewController(dateTimelineVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Load the other storyboard
        let storyboard = UIStoryboard(name: "DayPages", bundle: nil)
        
        // Instantiate the DateTimelineViewController directly
        if let daySlideshowVC = storyboard.instantiateViewController(withIdentifier: "DayPageID") as? DaySlideshowViewController {
            
            // Push onto the current navigation stack
            self.navigationController?.pushViewController(daySlideshowVC, animated: true)
        }
    }
    
    @objc func updateColorScheme() {
        timelineTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        addToTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        timelineSettingsButton.tintColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @IBAction func addToTimelinePressed(_ sender: Any) {
        // Load the other storyboard
        let storyboard = UIStoryboard(name: "IndividualTimeline", bundle: nil)

        if let addToTimelineVC = storyboard.instantiateViewController(withIdentifier: "AddToTimelineID") as? AddToTimelineViewController {

            // Push onto the current navigation stack
            self.navigationController?.pushViewController(addToTimelineVC, animated: true)
        }
    }
}
