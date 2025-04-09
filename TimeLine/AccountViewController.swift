//
//  AccountViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountViewController: UIViewController {

    @IBOutlet weak var myAccountTitleLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountUserNameLabel: UILabel!
    @IBOutlet weak var accountEmailLabel: UILabel!
    @IBOutlet weak var accountUserEmailLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        myAccountTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        accountNameLabel.font = UIFont.appFont(forTextStyle: .headline, weight: .bold)
        accountEmailLabel.font = UIFont.appFont(forTextStyle: .headline, weight: .bold)
        logOutButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        deleteAccountButton.titleLabel?.font = UIFont.appFont(forTextStyle: .caption2, weight: .regular)
        
        // fetch info from Firebase
        let user = Auth.auth().currentUser
        if let user = user {
            let currUserEmail = user.email
            db.collection("users").whereField("email", isEqualTo: currUserEmail!).getDocuments() { (snapshot, error) in
                if let error = error {
                    print("error fetching document: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("no matching document found")
                    return
                }
                // update fields to reflect this user
                let document = documents.first
                let data = document?.data()
                let username = data?["username"] as? String ?? "no username found"
                self.accountUserNameLabel.text = username
                self.accountUserEmailLabel.text = currUserEmail
            }
        }
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
}
