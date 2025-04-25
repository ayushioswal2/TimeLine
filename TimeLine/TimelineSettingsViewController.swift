//
//  SettingsDateTimelineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/12/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TimelineSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var settingsTitleLabel: UILabel!
    @IBOutlet weak var timelineNameLabel: UILabel!
    @IBOutlet weak var timelineNameField: UILabel!
    @IBOutlet weak var creatorsLabel: UILabel!
    @IBOutlet weak var inviteCreatorsLabel: UILabel!
    
    @IBOutlet weak var emailForInviteField: UITextField!
    @IBOutlet weak var creatorListTable: UITableView!
    @IBOutlet weak var dummyCoverPhotoView: UIView!
    @IBOutlet weak var coverPhotoView: UIImageView!
    
    var creatorList: [String] = []
    var db: Firestore!
    var currUserEmail: String?
    var userDocumentID: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        
        settingsTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .medium)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        timelineNameField.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        creatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        inviteCreatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)

        settingsTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
        coverPhotoView.image = currTimelineCoverImage ?? UIImage(systemName: "photo.badge.plus")
        
        timelineNameField.text = currTimeline?.name
        
        fetchCreators()
        
        creatorListTable.dataSource = self
        creatorListTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCreators()
    }
    
    @objc func updateFont() {
        settingsTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .medium)
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .body, weight: .medium)
        timelineNameField.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        creatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        inviteCreatorsLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        settingsTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creatorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatorCell", for: indexPath) as! CreatorListViewCell
        cell.creatorNameLabel.text = creatorList[indexPath.row]

        return cell
    }
    
    @IBAction func sendInviteButtonPressed(_ sender: Any) {
        Task {
            await sendInvite()
        }
    }
    
    func sendInvite() async {
        guard let inviteeEmail = emailForInviteField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !inviteeEmail.isEmpty else {
            print("Please enter a valid email")
            return
        }

        let db = Firestore.firestore()

        do {
            // Get the invitee user doc
            let userSnapshot = try await db.collection("users")
                .whereField("email", isEqualTo: inviteeEmail)
                .getDocuments()

            guard let userDoc = userSnapshot.documents.first else {
                print("User not found")
                return
            }

            let userRef = userDoc.reference
            let currentInvites = userDoc["invites"] as? [[String: Any]] ?? []

            if currentInvites.contains(where: { $0["timelineID"] as? String == currTimelineID }) {
                print("User already invited")
                return
            }

            // Get current user's username to include in invite
            guard let currentUserEmail = Auth.auth().currentUser?.email else {
                print("Current user email not found")
                return
            }

            let inviterSnapshot = try await db.collection("users")
                .whereField("email", isEqualTo: currentUserEmail)
                .getDocuments()

            guard let inviterDoc = inviterSnapshot.documents.first else {
                print("Inviter document not found")
                return
            }

            let inviterUsername = inviterDoc["username"] as? String ?? "Unknown"

            let newInvite: [String: Any] = [
                "timelineID": currTimelineID,
                "timelineName": currTimeline?.name ?? "timeline",
                "inviterName": inviterUsername,
                "status": "pending"
            ]

            try await userRef.updateData([
                "invites": FieldValue.arrayUnion([newInvite])
            ])

            // Update UI
            DispatchQueue.main.async {
                self.emailForInviteField.text = ""
            }

        } catch {
            print("Error sending invite: \(error.localizedDescription)")
        }
    }
    
    func fetchCreators() {
        self.creatorList = currTimeline?.creators ?? []
    }
    
    @IBAction func editTimelineNamePressed(_ sender: Any) {
        let controller = UIAlertController(title: "Edit Timeline Name", message: "", preferredStyle: .alert)
        
        controller.addTextField { (textField) in
            textField.text = ""
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default)
                {(action) in
            let newName = controller.textFields![0].text
            
            // check that new name is given for sure
            currTimeline?.name = newName!
            self.timelineNameField.text = newName
            
            Task {
                await self.changeTimelineName(newName!)
            }
            
            Task {
                await self.updateUserTimelines(newName!)
            }
        })
        
        present(controller, animated: true)
    }
    
    func changeTimelineName(_ newName: String) async {
        do {
            let document = try await db.collection("timelines").document(currTimelineID).getDocument()
            
            guard document.data() != nil else {
                print("No data found in document")
                return
            }

            try await document.reference.updateData([
                "timelineName": newName
            ])
        } catch {
            print("Firestore fetch error: \(error.localizedDescription)")
        }
    }
    
    func updateUserTimelines(_ newName: String) async {
        do {
            try await db.collection("users").document(userDocumentID!).updateData([
                "timelines.\(currTimelineID)": newName
            ])
        } catch {
            print("error adding document: \(error)")
        }
    }
    
    @IBAction func deleteTimelinePressed(_ sender: Any) {
        let controller = UIAlertController(title: "Delete Timeline", message: "Are you sure you want to delete this timeline? This action will remove the timeline for all users.", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            Task {
                await self.deleteTimeline()
            }
            Task {
                await self.deleteTimelineFromUsers()
            }
            
            deletionOrLeaveOccurred = true
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }

        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true)
    }
    
    // delete a timeline from Timelines collection
    func deleteTimeline() async {
        do {
            try await db.collection("timelines").document(currTimelineID).delete()
        } catch {
            print("error deleting document: \(error)")
        }
    }
    
    // delete a timeline from users collection
    func deleteTimelineFromUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            
            for document in snapshot.documents {
                let userID = document.documentID
                let data = document.data()

                // check if user is creator for this timeline
                if let timelines = data["timelines"] as? [String: Any],
                   timelines.keys.contains(currTimelineID) {
                    try await db.collection("users").document(userID).updateData([
                        "timelines.\(currTimelineID)": FieldValue.delete()
                    ])
                }
                
                // delete timeline from invites map for users invited to currTimeline
                if var invites = data["invites"] as? [[String: Any]] {
                    invites.removeAll { ($0["timelineID"] as? String) == currTimelineID }
                    try await db.collection("users").document(userID).updateData(["invites": invites])
                }
            }
        } catch {
            print("error deleting document: \(error)")
        }
    }
    
    @IBAction func leaveTimelinePressed(_ sender: Any) {
        let controller = UIAlertController(title: "Are you sure you want to leave this timeline?", message: nil, preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { (action) in
            Task {
                await self.leaveTimeline()
            }
            
            deletionOrLeaveOccurred = true
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        present(controller, animated: true)
    }
    
    func leaveTimeline() async {
        do {
            let snapshot = try await db.collection("timelines").document(currTimelineID).getDocument()
            
            guard let data = snapshot.data() else { return }
            
            var creators = data["creators"] as! [String]
            
            // check if only user in timeline -  if so let user know timeline will be deleted (also need to remove timeline in general)
            if creators.count == 1 { // curr user is only creator
                Task {
                    await self.deleteTimeline()
                }
                Task {
                    await self.deleteTimelineFromUsers()
                }
            } else { // multiple users - only remove this user
                do {
                    // remove user as a creator
                    creators.removeAll(where: { $0 == self.currUserEmail })
                    try await db.collection("timelines").document(currTimelineID).updateData([
                        "creators": creators
                    ])
                    
                    // remove the timeline from the user's document
                    try await db.collection("users").document(userDocumentID!).updateData([
                        "timelines.\(currTimelineID)": FieldValue.delete()
                    ])
                    
                } catch {
                    print("error leaving timeline: \(error)")
                }
            }
        } catch {
            print("error leaving timeline: \(error)")
        }
    }
}
