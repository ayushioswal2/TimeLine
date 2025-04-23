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
    
    @IBOutlet weak var imageBackground: UIView!
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
        
        imageBackground.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
    
    @objc func updateFont() {
        timelineCreationTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .title3, weight: .medium)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .headline, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
    }
    
    @IBAction func createTimelinePressed(_ sender: Any) {
        // To-Do: Add check for empty name field
        if timelineNameField.hasText {
            self.performSegue(withIdentifier: "CreateTimelinetoDateSegue", sender:nil)
            
            // create timeline in Firestore database
            Task {
                await self.createTimeline(name: timelineNameField.text!)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Timeline name cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
    }
    
    func createTimeline(name: String) async {        
        do {
            let ref = try await db.collection("timelines").addDocument(data: [
                "timelineName": name,
                "coverPhotoURL": self.timelineCoverPhotoURL,
                "creators": [self.currUserEmail]
            ])
            let newTimelineID = ref.documentID
            print("document \(newTimelineID) successfully added")
            print("new name: \(name)")
            print("currName: \(String(describing: currTimeline?.name))")
            userTimelines[newTimelineID] = name
            currTimelineID = newTimelineID
            currTimeline?.name = name
            print("currName: \(String(describing: currTimeline?.name))")
            try await db.collection("users").document(userDocumentID!).updateData([
                "timelines.\(newTimelineID)": name
            ])
            
            print("timelines updated to user")
        } catch {
            print("error adding document: \(error)")
        }
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        timelineNameField.text = ""
    }
    
    @IBAction func coverPhotoSelectPressed(_ sender: Any) {
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
            coverPhotoImageView.image = image
            
            if let imageURL = info[.imageURL] as? URL {
                // image chosen from camera library
                timelineCoverPhotoURL = imageURL.absoluteString
            } else {
                // Image was taken with camera – save it temporarily to get a URL
                if let tempURL = saveImageToTemporaryDirectory(image) {
                    timelineCoverPhotoURL = tempURL.absoluteString
                } else {
                    print("Failed to save camera image to temp directory")
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
    
    @objc func updateColorScheme() {
        timelineCreationTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        imageBackground.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
}
