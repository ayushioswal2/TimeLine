//
//  AccountViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/10/25.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var myAccountTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        myAccountTitleLabel.font = UIFont(name: "Refani", size: CGFloat(30))
    }
}
