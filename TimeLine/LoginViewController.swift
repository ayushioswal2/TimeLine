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
    
    func isValidEmail(_ email: String) -> Bool {
       let emailRegEx =
           "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailPred = NSPredicate(format:"SELF MATCHES %@",
           emailRegEx)
       return emailPred.evaluate(with: email)
    }
      
    func isValidPassword(_ password: String) -> Bool {
       let minPasswordLength = 6
       return password.count >= minPasswordLength
    }

    @IBAction func onSignInPressed(_ sender: Any) {
        guard isValidEmail(emailField.text!) && isValidPassword(passwordField.text!) else {
            self.errorMessageLabel.textColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
            
            var errorMessage = ""
            // getting weird error messages will fix later
//            if ((nameField?.text?.isEmpty) != nil) {
//                errorMessage += "\nName is required"
//                self.nameField.layer.borderWidth = 2
//                self.nameField.layer.borderColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
//                self.nameField.layer.cornerRadius = 10
//            }
            if !isValidEmail(emailField.text!) {
                errorMessage += "\nInvalid email format"
                self.emailField.layer.borderWidth = 2
                self.emailField.layer.borderColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
                self.emailField.layer.cornerRadius = 10
            }
            if !isValidPassword(passwordField.text!) {
                errorMessage += "\nPassword must be at least 6 characters long"
                self.passwordField.layer.borderWidth = 2
                self.passwordField.layer.borderColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
                self.passwordField.layer.cornerRadius = 10
            }
            
            self.errorMessageLabel.text = errorMessage

            return
        }
        
        Auth.auth().signIn(
            withEmail: emailField.text!,
            password: passwordField.text!) {
                (authResult, error) in
                if let error = error as NSError? {
                    print(error.localizedDescription)
                } else {
                    print("successful sign-in for \(self.emailField.text!)")
                    self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                    self.emailField.text = nil
                    self.passwordField.text = nil
                }
            }
    }
}
