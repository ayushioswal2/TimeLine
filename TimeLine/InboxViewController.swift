//
//  InboxViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/10/25.
//

import UIKit

class InboxViewController: UIViewController {
    @IBOutlet weak var inboxTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        inboxTitleLabel.font = UIFont(name: "Refani", size: CGFloat(30))

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
