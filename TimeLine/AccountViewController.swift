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
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountEmailLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        myAccountTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        accountNameLabel.font = UIFont.appFont(forTextStyle: .headline, weight: .bold)
        accountEmailLabel.font = UIFont.appFont(forTextStyle: .headline, weight: .bold)
        logOutButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        deleteAccountButton.titleLabel?.font = UIFont.appFont(forTextStyle: .caption2, weight: .regular)
        
        logOutButton.backgroundColor = UIColor.appColorScheme(type: "primary")
        profilePicImageView.tintColor = UIColor.appColorScheme(type: "primary")
        myAccountTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
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
    
    @objc func updateFont() {
        myAccountTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        accountNameLabel.font = UIFont.appFont(forTextStyle: .headline, weight: .bold)
        accountEmailLabel.font = UIFont.appFont(forTextStyle: .headline, weight: .bold)
        logOutButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        deleteAccountButton.titleLabel?.font = UIFont.appFont(forTextStyle: .caption2, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        logOutButton.backgroundColor = UIColor.appColorScheme(type: "primary")
        profilePicImageView.tintColor = UIColor.appColorScheme(type: "primary")
        myAccountTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
    }
}
