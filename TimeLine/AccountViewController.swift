//
//  AccountViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/10/25.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var myAccountTitleLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountUserNameLabel: UILabel!
    @IBOutlet weak var accountEmailLabel: UILabel!
    @IBOutlet weak var accountUserEmailLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var profilePicURL: String = ""
    
    var db: Firestore!
    var currUser: User?
    var userDocID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
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
        profilePicImageView.contentMode = .scaleAspectFill
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width / 2
        profilePicImageView.clipsToBounds = true
        myAccountTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        
        // fetch info from Firebase
        currUser = Auth.auth().currentUser
        let currUserEmail = currUser?.email!
        getUserDoc(currUserEmail: currUserEmail!) { docRef in
            if let docRef = docRef {
                docRef.getDocument { documentSnapshot, error in
                    if let error = error {
                        print("error getting document data: \(error)")
                        return
                    }
                    self.userDocID = docRef.documentID
                    let data = documentSnapshot?.data()
                    let username = data?["username"] as? String ?? "no username found"
                    self.accountUserNameLabel.text = username
                    self.accountUserEmailLabel.text = currUserEmail
                    if let profilePicString = data?["profilePicURL"] as? String, let url = URL(string: profilePicString) {
                        Task {
                            let (picData, _) = try await URLSession.shared.data(from: url)
                            let image = UIImage(data: picData)
                            
                            if let image = image {
                                self.profilePicImageView.image = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onLogOutPressed(_ sender: Any) {
        logOut()
        
        userTimelines = [:]
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
    
    @IBAction func onEditProfilePicturePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Select Photo", message: "Choose a source", preferredStyle: .actionSheet)
        
        // camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                self.presentPhotoPicker(sourceType: .camera)
            })
        }
        
        // photo library option
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        })
        
        // cancel image selection
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            profilePicImageView.image = image
            
            if let imageURL = info[.imageURL] as? URL {
                // image chosen from camera library
                profilePicURL = imageURL.absoluteString
            } else {
                // Image was taken with camera – save it temporarily to get a URL
                if let tempURL = saveImageToTemporaryDirectory(image) {
                    profilePicURL = tempURL.absoluteString
                } else {
                    print("Failed to save camera image to temp directory")
                }
            }
        }
        
        Task {
            await uploadProfilePicToStorage()
        }
    }
    
    func uploadProfilePicToStorage() async {
        guard let user = currUser else { return }
        let currUserEmail = user.email!
        do {
            if let image = self.profilePicImageView.image, let imageData = image.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child("users/\(userDocID)-profile-pic.jpg")
                
                let _ = try await imageRef.putDataAsync(imageData, metadata: nil)
                profilePicURL = try await imageRef.downloadURL().absoluteString
            }
        } catch {
            printContent(error)
        }
        
        getUserDoc(currUserEmail: currUserEmail) { docRef in
            if let docRef = docRef {
                docRef.updateData(["profilePicURL": self.profilePicURL]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("user has updated their profile picture")
                        
                    }
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveImageToTemporaryDirectory(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let filename = UUID().uuidString + ".jpg"
        let fileURL = tempDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    @IBAction func onEditNamePressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Update Username",
            message: "Please enter a new username.",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        controller.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        controller.addAction(UIAlertAction(
            title: "Save",
            style: .default)
                {(action) in
            let enteredText = controller.textFields![0].text
            self.updateUserName(newName: enteredText!)
        })
        
        present(controller,animated:true)
    }
    
    func updateUserName(newName: String) {
        guard let user = currUser else { return }
        let currUserEmail = user.email!
        getUserDoc(currUserEmail: currUserEmail) { docRef in
            if let docRef = docRef {
                docRef.updateData(["username": newName]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("username updated to \(newName)")
                        self.accountUserNameLabel.text = newName
                    }
                }
            }
        }
    }
    
    @IBAction func onEditEmailPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Update Email",
            message: "Please enter a new and unique email address.",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        controller.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        controller.addAction(UIAlertAction(
            title: "Save",
            style: .default)
                {(action) in
            let enteredText = controller.textFields![0].text
            self.updateUserEmail(newEmail: enteredText!)
        })
        
        present(controller,animated:true)
    }
    
    // Code from CS371L Code Library
    func isValidEmail(_ email: String) -> Bool {
       let emailRegEx =
           "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailPred = NSPredicate(format:"SELF MATCHES %@",
           emailRegEx)
       return emailPred.evaluate(with: email)
    }
    
    func updateUserEmail(newEmail: String) {
        guard isValidEmail(newEmail) else {
            print("invalid email!")
            return
        }
        guard let user = currUser else { return }
        let currUserEmail = user.email!
        getUserDoc(currUserEmail: currUserEmail) { docRef in
            if let docRef = docRef {
                docRef.updateData(["email": newEmail]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("username updated to \(newEmail)")
                    user.updateEmail(to: newEmail) {
                        error in
                        if let error = error { print("error updating email: \(String(describing: error))")
                        }
                    }
                    self.accountUserEmailLabel.text = newEmail
                    }
                }
            }
        }
    }
    
    @IBAction func onDeleteAccountPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be reversed.",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteAccount(alert:)))
        
        present(controller,animated:true)
    }
    
    func deleteAccount(alert: UIAlertAction) {
        if let user = currUser {
            let currUserEmail = user.email!
            user.delete { error in
                if let error = error {
                    print("an error occured while deleting this user's account")
                    return
                } else {
                    print("account successfully deleted")
                }
            }
            // also delete from users collection
            getUserDoc(currUserEmail: currUserEmail) { docRef in
                if let docRef = docRef {
                    docRef.delete { error in
                        if let error = error {
                            print("error deleting user doc: \(error)")
                            return
                        } else {
                            print("successfully deleted user collection")
                        }
                    }
                }
            }
            // if both successful, log out
            self.logOut()
        }
    }
    
    func getUserDoc(currUserEmail: String, completion: @escaping (DocumentReference?) -> Void) {
        db.collection("users").whereField("email", isEqualTo: currUserEmail).getDocuments() { (snapshot, error) in
            if let error = error {
                print("error fetching document: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("no matching document found")
                return
            }
            
            let docRef = documents[0].reference
            completion(docRef)
        }
    }
        
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "LogoutSegue", sender: nil)
            print("user successfully signed out")
        } catch {
            print("An error has occurred")
        }
    }
}
