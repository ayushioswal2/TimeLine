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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTitleLabel.font = UIFont(name: "Refani", size: CGFloat(50))
        loginTitleLabel.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        
//        var config = UIButton.Configuration.filled()
//        config.titlePadding = 10 // Adds space around the title
//        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
//        
//        loginButton.configuration = config
//            
//        // Round the corners
//        loginButton.layer.cornerRadius = 10
//        loginButton.clipsToBounds = true
        
        // doesn't work for some reason, immediately segues to Home screen on boot up
//        Auth.auth().addStateDidChangeListener() {
//            (auth, user) in
//            if user != nil {
//                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
//                self.emailField.text = nil
//                self.passwordField.text = nil
//            }
//            
//        }
    }

    @IBAction func onSignInPressed(_ sender: Any) {
        // placeholder for testing purposes, doesn't segue or anything
        Auth.auth().signIn(
            withEmail: emailField.text!,
            password: passwordField.text!) {
                (authResult, error) in
                if let error = error as NSError? {
                    print(error.localizedDescription)   // if password error, do the red message below it and red box, etc.
                    // or if username badly formatted, display that message and red box also
                } else {
                    print("successful sign-in for \(self.emailField.text!)")
                    self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                    self.emailField.text = nil
                    self.passwordField.text = nil
                }
            }
    }
}
