//
//  TimelineCreationViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/12/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TimelineCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var inviteCreatorsLabel: UILabel!
    @IBOutlet weak var timelineNameLabel: UILabel!
    
    @IBOutlet weak var timelineCreationTitleLabel: UILabel!
    
    @IBOutlet weak var createTimelineButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var timelineNameField: UITextField!
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    
    var timelineName: String = ""
    var timelineCoverPhotoURL: String = ""
    
    var db: Firestore!
    
    var currUserEmail: String?
    var userDocumentID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        // Initial Set Up
        setupUI()
        
        let currUser = Auth.auth().currentUser
        if let user = currUser {
            currUserEmail = user.email
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
                self.userDocumentID = document?.documentID
//                let data = document?.data()
//                let username = data?["username"] as? String ?? "no username found"
//                self.currUserName = username
            }
        }
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        timelineCreationTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        
        timelineCreationTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @objc func updateFont() {
        timelineCreationTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
    }
    
    @IBAction func createTimelinePressed(_ sender: Any) {
        // To-Do: Add check for empty name field
        let name = timelineNameField.text!
        self.performSegue(withIdentifier: "CreateTimelinetoDateSegue", sender:nil)
        timelines.append(name)
        
        // create timeline in Firestore database
        Task {
            await self.createTimeline(name: timelineNameField.text!)
        }
    }
    
    func createTimeline(name: String) async {        
        do {
            let ref = try await db.collection("timelines").addDocument(data: [
                "timelineName": name,
                "coverPhotoURL": "",
                "creators": [self.currUserEmail]
            ])
            print("document \(ref.documentID) successfully added")
            try await db.collection("users").document(userDocumentID!).updateData([
                "timelines": FieldValue.arrayUnion([name])
            ])
            print("timelines updated to user")
        } catch {
            print("error adding document: \(error)")
        }
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {

    }
    
    @IBAction func coverPhotoSelectPressed(_ sender: Any) {
        presentPhotoPicker()
    }
    
    func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            coverPhotoImageView.image = image
        }
        
        if let imageURL = info[.imageURL] as? URL {
            timelineCoverPhotoURL = imageURL.absoluteString
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func updateColorScheme() {
        timelineCreationTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
}
