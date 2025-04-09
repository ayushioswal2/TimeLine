//
//  SettingsDateTimelineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/12/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsDateTimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var settingsTitleLabel: UILabel!
    @IBOutlet weak var timelineNameLabel: UILabel!
    @IBOutlet weak var timelineNameField: UILabel!
    @IBOutlet weak var creatorsLabel: UILabel!
    @IBOutlet weak var inviteCreatorsLabel: UILabel!
    
    @IBOutlet weak var emailForInviteField: UITextField!
    
    @IBOutlet weak var creatorListTable: UITableView!
    var creatorList: [String] = ["Tester1", "Tester2"]
    
    @IBOutlet weak var dummyCoverPhotoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        creatorListTable.dataSource = self
        creatorListTable.delegate = self
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

            let selectedTimelineName = "testerTL1" // Replace with value we pull from firebase of this timeline
            var timelineID: String?

            do {
                // Get the Timeline ID
                let timelineSnapshot = try await db.collection("timelines")
                    .whereField("timelineName", isEqualTo: selectedTimelineName)
                    .getDocuments()

                guard let timelineDoc = timelineSnapshot.documents.first else {
                    print("Timeline not found")
                    return
                }

                timelineID = timelineDoc.documentID
                let timelineName = timelineDoc["timelineName"] as? String ?? "timeline"

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

                if currentInvites.contains(where: { $0["timelineID"] as? String == timelineID }) {
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
                    "timelineID": timelineID!,
                    "timelineName": timelineName,
                    "inviterName": inviterUsername,
                    "status": "pending"
                ]

                try await userRef.updateData([
                    "invites": FieldValue.arrayUnion([newInvite])
                ])

                print("Invite sent to \(inviteeEmail)")

                // Update UI
                DispatchQueue.main.async {
                    self.creatorList.append(inviteeEmail)
                    self.creatorListTable.reloadData()
                    self.emailForInviteField.text = ""
                }

            } catch {
                print("Error sending invite: \(error.localizedDescription)")
            }
        }


    
    
    
}
