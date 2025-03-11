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
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTitleLabel.font = UIFont(name: "Refani", size: CGFloat(50))
        loginTitleLabel.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        errorMessageLabel.text = ""
        
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
                    // change the border of the textbox
                    self.passwordField.layer.borderWidth = 2
                    self.passwordField.layer.borderColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
                    self.passwordField.layer.cornerRadius = 10
                    // alter the error message text
                    self.errorMessageLabel.text = "Invalid email or password"
                    self.errorMessageLabel.textColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
                } else {
                    print("successful sign-in for \(self.emailField.text!)")
                    self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                    self.emailField.text = nil
                    self.passwordField.text = nil
                }
            }
    }
}
