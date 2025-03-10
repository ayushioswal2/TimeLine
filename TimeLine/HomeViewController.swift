//
//  HomeViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/9/25.
//

import UIKit

var timelines: [String] = ["Personal Timeline", "The FAM", "AAA"]

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
        timelineTitle.font = UIFont(name: "Refani", size: CGFloat(25))
        timelineTitle.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        homeTitleBar.titleView = timelineTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: timelineCellIdentifier, for: indexPath) as! TimelineTableViewCell
//        cell.textLabel?.text = timelines[indexPath.row]
        cell.timelineNameLabel.text = timelines[indexPath.row]
        cell.timelineNameLabel.font = UIFont(name: "Refani", size: CGFloat(20))
        
//        cell.timelineCoverImageView.image = UIImage(systemName: "")
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
}
