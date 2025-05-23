//
//  SignupViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/9/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController {

    @IBOutlet weak var signupTitleLabel: UILabel!
    @IBOutlet weak var nameFieldLabel: UILabel!
    @IBOutlet weak var emailFieldLabel: UILabel!
    @IBOutlet weak var passwordFieldLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var verifyPasswordField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var signupButton: UIButton!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        // Do any additional setup after loading the view.
        signupTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        signupTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        self.errorMessageLabel.text = ""
        
        signupButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        signupButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @IBAction func onSignUpPressed(_ sender: Any) {
        guard isValidEmail(emailField.text!) && isValidPassword(passwordField.text!) && passwordField.text == verifyPasswordField.text && !(nameField.text!).isEmpty else {
            self.errorMessageLabel.textColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
            
            var errorMessage = ""

            if (nameField.text!).isEmpty {
                errorMessage += "\nUsername cannot be empty"
                self.emailField.layer.borderWidth = 2
                self.emailField.layer.borderColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
                self.emailField.layer.cornerRadius = 10
            }
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
            if passwordField.text != verifyPasswordField.text {
                errorMessage += "\nPasswords do not match"
                self.verifyPasswordField.layer.borderWidth = 2
                self.verifyPasswordField.layer.borderColor = .init(red: 168/255, green: 20/255, blue: 20/255, alpha: 1)
                self.verifyPasswordField.layer.cornerRadius = 10
            }
            
            self.errorMessageLabel.text = errorMessage

            return
        }
        
        Auth.auth().createUser(withEmail: emailField.text!,
                               password: passwordField.text!) {
            (authResult,error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
            } else {
                Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) {
                    (authResult,error) in
                    if let error = error as NSError? {
                        print(error.localizedDescription)
                    } else {
                        print("successful sign-in for \(self.emailField.text!)")
                        let username = self.nameField.text!
                        let email = self.emailField.text!
                        let password = self.passwordField.text!
                        self.performSegue(withIdentifier: "SignupSegue", sender:nil)
                        self.emailField.text = nil
                        self.passwordField.text = nil
                        
                        // also create user in Firestore database with their information
                        Task {
                            await self.createUser(name: username, email: email, password: password)
                        }
                    }
                }
            }
        }
    }
    
    func createUser(name: String, email: String, password: String) async {
        do {
            let ref = try await db.collection("users").addDocument(data: [
                "username": name,
                "email": email,
                "password": password,
                "timelines": [:],
                "invites": [],
            ])
            print("document \(ref.documentID) successfully added")
        } catch {
            print("error adding document: \(error)")
        }
    }
    
    // Code from CS371L Code Library
    func isValidEmail(_ email: String) -> Bool {
       let emailRegEx =
           "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailPred = NSPredicate(format:"SELF MATCHES %@",
           emailRegEx)
       return emailPred.evaluate(with: email)
    }
      
    // Code from CS371L Code Library
    func isValidPassword(_ password: String) -> Bool {
       let minPasswordLength = 6
       return password.count >= minPasswordLength
    }
    
    @objc func updateFont() {
        signupTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        signupButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
    }
    
    @objc func updateColorScheme() {
        signupTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        signupButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
}
