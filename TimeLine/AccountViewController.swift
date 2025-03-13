//
//  AccountViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/10/25.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {

    @IBOutlet weak var myAccountTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        myAccountTitleLabel.font = UIFont(name: "Refani", size: CGFloat(30))
    }
    
    @IBAction func onLogOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "LogoutSegue", sender: nil)
            print("user successfully signed out")
        } catch {
            print("An error has occurred")
        }
    }
}
