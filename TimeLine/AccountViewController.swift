//
//  AccountViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sideMenuButton.target = revealViewController()
        sideMenuButton.action = #selector(revealViewController()?.revealSideMenu)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
