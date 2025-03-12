//
//  HomeViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/9/25.
//

import UIKit

var timelines: [String] = ["Personal Timeline", "The FAM"]

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTitleBar: UINavigationItem!
    @IBOutlet weak var timelinesTableView: UITableView!
    
    let timelineTitle = UILabel()
    
    let timelineCellIdentifier = "timelineCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelinesTableView.delegate = self
        timelinesTableView.dataSource = self

        timelineTitle.text = "My Timelines"
        timelineTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineTitle.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        homeTitleBar.titleView = timelineTitle
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: timelineCellIdentifier, for: indexPath) as! TimelineTableViewCell
        cell.timelineNameLabel.text = timelines[indexPath.row]
                
//        let imageName = "holyrood_park.jpg"
//        let image = UIImage(named: imageName)
//        cell.timelineCoverImageView.image = image
        return cell
    }
    
    @IBAction func createTimelinePressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Create timeline",
            message: "Enter timeline name",
            preferredStyle: .alert)
        
        controller.addTextField { (textField) in
            textField.placeholder = "name"
        }
        
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default)
                {(action) in
            let enteredName = controller.textFields![0].text
            timelines.append(enteredName!)
            self.timelinesTableView.reloadData()
        })
        
        present(controller, animated: true)
    }
    
    @objc func updateFont() {
        timelineTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }
}
