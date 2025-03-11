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
                    self.passwordField.layer.borderWidth = 2
                    self.passwordField.layer.borderColor = .init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                    self.passwordField.layer.cornerRadius = 10

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
