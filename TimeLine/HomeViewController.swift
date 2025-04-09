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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timelinesTableView.reloadData()
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
        homeTitle.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateFont() {
        homeTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @IBAction func createNewTimelinePressed(_ sender: Any) {
//        performSegue(withIdentifier: "toTimelineCreationID", sender: sender)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Load the other storyboard
        let storyboard = UIStoryboard(name: "IndividualTimeline", bundle: nil)
        
        // Instantiate the DateTimelineViewController directly
        if let dateTimelineVC = storyboard.instantiateViewController(withIdentifier: "DateTimelineStoryboard") as? DateTimlineViewController {
            
            // Push onto the current navigation stack
            self.navigationController?.pushViewController(dateTimelineVC, animated: true)
        }
    }
    
}
