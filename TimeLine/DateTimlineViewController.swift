//
//  DateTimlineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/11/25.
//

import UIKit

class DateTimlineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var datesTableView: UITableView!
    @IBOutlet weak var timelineTitleLabel: UILabel!
    
    var dates: [String] = ["March 11th, 2025", "April 12th, 2025"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        timelineTitleLabel.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)

        timelineTitleLabel.font = UIFont(name: "Refani", size: CGFloat(30))
        datesTableView.dataSource = self
        datesTableView.delegate = self
        self.datesTableView.separatorStyle = UITableViewCell.SeparatorStyle.none

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = dates[indexPath.row]
        return cell
    }

}
