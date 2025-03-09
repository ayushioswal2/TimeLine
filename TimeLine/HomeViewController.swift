//
//  HomeViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/9/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var homeTitleBar: UINavigationItem!
    let timelineTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timelineTitle.text = "My Timelines"
        timelineTitle.font = UIFont(name: "Refani", size: CGFloat(25))
//        timelineTitle.textColor =
        homeTitleBar.titleView = timelineTitle
    }
    
}
