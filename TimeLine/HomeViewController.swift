//
//  HomeViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/9/25.
//

import UIKit

var timelines: [String] = ["Personal Timeline", "The FAM"]

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTitle: UILabel!
    @IBOutlet weak var createTimelineButton: UIButton!
    @IBOutlet weak var timelinesTableView: UITableView!
    
    let timelineTitle = UILabel()
    
    let timelineCellIdentifier = "timelineCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        timelinesTableView.delegate = self
        timelinesTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: timelineCellIdentifier, for: indexPath) as! TimelineTableViewCell
        cell.timelineNameLabel.text = timelines[indexPath.row]

        return cell
    }
    
    func setupUI() {
        homeTitle.text = "My Timelines"
        homeTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        homeTitle.textColor = UIColor.appColorScheme(type: "primary")
        
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @objc func updateFont() {
        homeTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        homeTitle.textColor = UIColor.appColorScheme(type: "primary")
    }
}
