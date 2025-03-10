//
//  LoginViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/9/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTitleLabel: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!  // testing can delete !
    
    @IBOutlet weak var passwordField: UITextField! // testing can delete !
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTitleLabel.font = UIFont(name: "Refani", size: CGFloat(50))
        loginTitleLabel.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
    }

    @IBAction func onSignInPressed(_ sender: Any) {
        // placeholder for testing purposes, doesn't segue or anything
        Auth.auth().signIn(
            withEmail: usernameField.text!,
            password: passwordField.text!) {
                (authResult, error) in
                if let error = error as NSError? {
                    print(error.localizedDescription)   // if password error, do the red message below it and red box, etc.
                    // or if username badly formatted, display that message and red box also
                } else {
                    print("successful sign-in for \(self.usernameField.text!)")
                }
            }
    }
}
