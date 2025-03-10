//
//  SignupViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/9/25.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var signupTitleLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var verifyPasswordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signupTitleLabel.font = UIFont(name: "Refani", size: CGFloat(50
                                                                    ))
        signupTitleLabel.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        
        // doesn't work for some reason same as login
//        Auth.auth().addStateDidChangeListener() {
//            (auth,user) in
//            if user != nil {
//                self.performSegue(withIdentifier: "SignupSegue", sender:nil)
//                self.emailField.text = nil
//                self.passwordField.text = nil
//            }
//        }

    }
    

    @IBAction func onSignUpPressed(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailField.text!,
                               password: passwordField.text!) {
            (authResult,error) in
            if let error = error as NSError? {
                print(error.localizedDescription)   // if password error, do the red message below it and red box, etc.
                // or if username badly formatted, display that message and red box also
            } else {
                print("successful sign-in for \(self.emailField.text!)")
                self.performSegue(withIdentifier: "SignupSegue", sender:nil)
                self.emailField.text = nil
                self.passwordField.text = nil
            }
            
        }
    }
    
}
